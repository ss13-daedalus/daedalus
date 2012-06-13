// Component Name: SQLite wrapper for BYOND DreamMaker scripts
//
// Copyright (C) 2012 Wojciech Stryjewski <thvortex@gmail.com>
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
//

#include <sstream>
#include <string>
#include <set>
#include <string.h>
#include "sqlite3.h"

// The strcasecmp() and strncasecmp() functions are specified by POSIX but are
// not by ANSI C. On Windows, these functions have alternate names.
#ifdef _WIN32
#define strcasecmp _stricmp
#define strncasecmp _strnicmp
#endif

// Any pointer value returned by this wrapper library is added into one of the
// pointer_set_t sets. For safety purposes, when that handle is returned by
// the BYOND script as an argument, it will be checked against the appropriate
// set to verify that it is indeed one of the handle values returned before.
typedef std::set<void *> pointer_set_t;

// The set of all handles to open database files
static pointer_set_t dbconn_set;

// The set of all handles to prepared SQL statements
static pointer_set_t stmt_set;

// A placeholder for the last result string returned to the BYOND server
// by one of the dm_db_xxx() methods. This ensures the returned char pointer
// remains valid until the next dm_db_xxx() call.
static std::string result_string;

// If any error has occurred during the execution of a dm_db_xxx() method,
// this pointer will hold a reference to error message which can be
// later retrieved by dm_db_error_msg(). If the last dm_xxx() method produced
// no error, then this variable will be set to NULL.
static const char *error_string = NULL;

// Static error messages used by get_handle() when verifying database handles
static const char *DBCONN[] = {
	"Database handle is required",
	"Database handle is not valid or is already closed"
};

// Static error messages used by get_handle() when verifying statement handles
static const char *STMT[] = {
	"Query handle is required",
	"Query handle is not valid or is already closed"
};

// Reserved device names (case-insensitive) under Windows which cannot be used
// for a normal file, and cannot be used as a pathname component.
// See the MSDN article "Naming Files, Paths, and Namespaces" for details:
// http://msdn.microsoft.com/en-us/library/aa365247.aspx
static const char *RSVD_FILE_NAMES[] = {
	"CON", "PRN", "AUX", "NUL", "COM1", "COM2", "COM3", "COM4", "COM5",
	"COM6", "COM7", "COM8", "COM9", "LPT1", "LPT2", "LPT3", "LPT4", "LPT5",
	"LPT6", "LPT7", "LPT8", "LPT9", NULL
	// Note that the entire array must be NULL terminated
};

// ASCII control characters that may not be used in database pathnames
static const char *RSVD_CTRL_CHARS =
	"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F";

// Reserved characters that may not be used in the pathname to a database
// file. These have either special meaning to a POSIX shell, or in the
// case of the colon (:) to Windows and the Mac OSX Finder.
#define RSVD_FILE_CHARS "\\:;*?\"'`<>|{}"

// Helper function to decode the database or statement handle passed as the
// first or second arguemnts in most dm_db_xxx() methods. The handle is just
// a numeric encoding of the pointer values returned by SQLite functions. For
// safety, this function verifies that the handle has been previously seen by
// this native library.
//
// argc: Number of arguments passed in by BYOND script
// argv[argn]: The handle to parse and verify
// argn: The argument number which should be read
// set: Handle is considered valid if it exists inside this set
// errors: Array of error messages specific to the handle set used
//
// Return: the handle value converted to a pointer if the handle was valid,
// and NULL otherwise.
static void *get_handle(int argc, char *argv[], int argn,
	const pointer_set_t &set, const char *errors[])
{
	// Check for usage: a handle argument is required
	if(argc < (argn + 1)) {
		error_string = errors[0];
		return NULL;
	}

	// Convert the string argument into a numeric pointer value
	std::istringstream buffer(argv[argn]);
	void *pointer;
	buffer >> pointer;

	// Check if argument was parsable and is in the set of valid pointers
	if(buffer.fail() || set.find(pointer) == set.end()) {
		error_string = errors[1];
		return NULL;
	}

	// Return the real open SQLite database handle if it was found
	return pointer;
}

// Authorization callback which verifies that a database pathname specified by
// a BYOND script is safe to use. Only path names within the game directory
// are allowed (cannot start with / or contain ..). Any characters in the path
// with special meaning to a POSIX shell or to Windows are also not allowed.
// These checks are based on "Secure Programming for Linux and Unix HOWTO" by
// David A. Wheeler. See http://www.dwheeler.com/secure-programs/
//
// This function is called manually by dm_db_open() and automatically by
// SQLite itself when executing the "ATTACH DATABASE" SQL statement.
//
// userdata: NULL (not used); 3rd argument in sqlite3_set_authorizer()
// action: Action to be authorized; only SQLITE_ATTACH checked
// pathname: The pathname to be validated when action==SQLITE_ATTACH
// unused: Not used with SQLITE_ATTACH
// dbname: Name of already open database; not used for verification
// trigger: The inner-most trigger of view responsible for action; not used
//
// Return: SQLITE_OK to allow the action; SQLITE_DENY to cancel the action
// and return a SQLITE_AUTH error from the SQLite API function. If an action
// is denied, _error_string is also set to provide a detailed error message.
static int authorizer(void *userdata, int action, const char* pathname,
	const char *unused, const char *dbname, const char *trigger)
{
	// Any action other than a database attach is always allowed
	if(action != SQLITE_ATTACH) {
		return SQLITE_OK;
	}

	// This should never happen for SQLITE_ATTACH action codes
	if(pathname == NULL) {
		error_string = "Internal error: SQLITE_ATTACH with "
			"NULL pathname";
		return SQLITE_DENY;
	}

	size_t length = strlen(pathname);

	// Do not allow any ASCII control characters in the pathname
	if(strcspn(pathname, RSVD_CTRL_CHARS) != length) {
		error_string = "Database file path may not contain "
			"control characters";
		return SQLITE_DENY;
	}

	// Do not allow any reserved characters in the pathname
	if(strcspn(pathname, RSVD_FILE_CHARS) != length) {
		error_string = "Database file path may not contain "
			RSVD_FILE_CHARS " characters";
		return SQLITE_DENY;
	}

	// Do not allow absolute pathnames that start with a /
	if(pathname[0] == '/') {
		error_string = "Database file path may not start with \"/\"";
		return SQLITE_DENY;
	}

	// Split string along the / path separator for individual filename checks.
	// The name variable always points to the beginning of the next path
	// component (i.e. directory or filename) in the string, or points to the
	// terminating NULL character if the entire string has been searched.
	const char *name = pathname;
	while(*name) {
		// If / not found in string, then use remaining length of the string
		const char *next = strchr(name, '/');
		if(next == NULL) {
			next = pathname + length;
		}

		// Check for .. directory names that could escape the game directory
		if(strncmp(name, "..", next - name) == 0) {
			error_string = "Database file path may not contain .. parent "
				"directory";
			return SQLITE_DENY;
		}

		// POSIX command may treat a file that starts with - as option name
		if(*name == '-') {
			error_string = "Database file path may not start file with \"-\"";
			return SQLITE_DENY;
		}

		// Files starting with . are "hidden" in POSIX and need "ls -a" to list
		if(*name == '.') {
			error_string = "Database file path may not start file with \".\"";
			return SQLITE_DENY;
		}

		// Check for any of the case-insensitive reserved names Windows has
		for(int i = 0; RSVD_FILE_NAMES[i]; i++) {
			if(strncasecmp(name, RSVD_FILE_NAMES[i], next - name) == 0) {
				error_string = "Database file path may not use "
					"CON, PRN, AUX, NUL, COMn, LPTn";
				return SQLITE_DENY;
			}
		}

		// Skip over the / separator to match the next component, unless this
		// was the last path component and next points to the terminating NULL.
		name = next;
		if(*name) {
			name++;
		}
	}

	// The filename must be ok if it passed all the above checks
	return SQLITE_OK;
}

// Return a human readable message with a description of the error if the last
// call to one of the dm_db_xxx() functions failed and in turn returned NULL.
// If the last call to the library succeeded, then this function returns NULL
// since there is no error to report.
//
// argc, argv: Ignored.
// Return: The error message string or NULL if there was no error
extern "C" const char *dm_db_error_msg(int argc, char *argv[])
{
	return error_string;
}

// Open a new database connection to the filename specified in argv[0]. If
// the connection is successful, returns a handle (pointer value encoded to
// a string) to the open connection. Most other dm_db_xxx() functions require
// the BYOND script to pass this handle value back in, so the function can
// operate on the appropriate database faile.
//
// argc: Number of arguments passed in by BYOND script
// argv[0]: The filename of the database file to open (and maybe create)
//
// Return: The handle to the open database connection or NULL on error.
extern "C" const char *dm_db_open(int argc, char *argv[])
{
	// Check for usage: a single filename argument is required
	if(argc < 1) {
		error_string = "Database filename is required as 1st argument";
		return NULL;
	}

	// Check if the database filename is valid
	int rc = authorizer(NULL, SQLITE_ATTACH, argv[0], NULL, NULL, NULL);
	if(rc != SQLITE_OK) {
		// error_string already set by authorizer() on error
		return NULL;
	}

	// Attempt to open a SQLite database and check for library errors
	sqlite3 *dbconn;
	rc = sqlite3_open(argv[0], &dbconn);

	// If database cannot be opened, save error message and close handle
	if(rc != SQLITE_OK) {
		error_string = sqlite3_errmsg(dbconn);
		sqlite3_close(dbconn);
		return NULL;
	}

	// Setup authorizer to verify "ATTACH DATABASE" statements
	rc = sqlite3_set_authorizer(dbconn, authorizer, NULL);
	if(rc != SQLITE_OK) {
		error_string = sqlite3_errmsg(dbconn);
		sqlite3_close(dbconn);
		return NULL;
	}

	// Add dbconn handle to set of valid pointers and convert it to a string
	dbconn_set.insert(dbconn);
	std::ostringstream result;
	result << dbconn;

	// Convert ostringstream to a persistant C string that can be returned
	error_string = NULL;
	result_string = result.str();
	return result_string.c_str();
}

// Close a database connection that was previously opened with dm_db_open().
//
// argc: Number of arguments passed in by BYOND script
// argv[0]: Database handle to close; returned by previous dm_db_open() call
//
// Return: An empty "" string on success and NULL on error.
extern "C" const char *dm_db_close(int argc, char *argv[])
{
	// Decode the database handle from the first argument
	sqlite3 *dbconn;
	dbconn = (sqlite3 *) get_handle(argc, argv, 0, dbconn_set, DBCONN);
	if(dbconn == NULL) {
		return NULL;
	}

	// Finalize any exisitng prepared statement the connection may still have
	sqlite3_stmt *stmt = sqlite3_next_stmt(dbconn, NULL);
	while(stmt != NULL) {
		sqlite3_stmt* prev = stmt;
		stmt = sqlite3_next_stmt(dbconn, stmt);

		// Finalize can only return previous statment error so ignore it here
		sqlite3_finalize(prev);

		// Remove prepared statement handle from set of valid pointers
		stmt_set.erase(prev);
	}

	// Close the database itself and check for any errors on close
	int rc = sqlite3_close(dbconn);
	if(rc != SQLITE_OK) {
		error_string = sqlite3_errmsg(dbconn);
		return NULL;
	}

	// Remove handle from pointer set; return empty string indicating success
	dbconn_set.erase(dbconn);
	error_string = NULL;
	return "";
}

// Prepare and execute SQL statement on previously opened database connection.
// This function uses sqlite3_prepate_v2() to prepare and compile the SQL
// statement, followed by a single sqlite3_step() call to actually execute it.
// If the statement returned any data, it will be later retrieved with the
// BYOND script calling dm_db_next_row(). The statement handle returned by
// this function must also be closed later on with dm_db_finalize() before
// closing the database connection itself.
//
// argc: Number of arguments passed in by BYOND script
// argv[0]: Database handle in which to execute SQL statement
// argv[1]: The SQL statement itself
//
// Return: A handle to the prepared SQL statement which is needed laster to
// retrieve any data produced by the statement, or NULL if an error occurred
// with either the prepare/compile step or the actual execution.
extern "C" const char *dm_db_execute(int argc, char *argv[])
{
	// Decode the database handle from the first argument
	sqlite3 *dbconn;
	dbconn = (sqlite3 *) get_handle(argc, argv, 0, dbconn_set, DBCONN);
	if(dbconn == NULL) {
		return NULL;
	}

	// Check that a second argument was passed in with the SQL string
	if(argc < 2) {
		error_string = "SQL statement is required as 2nd argument";
		return NULL;
	}

	// Compile the SQL statement, check for errors, and save its handle
	sqlite3_stmt *stmt;
	int rc = sqlite3_prepare_v2(dbconn, argv[1], -1, &stmt, NULL);
	if(rc != SQLITE_OK) {
		// error string already set by authorizer() on error
		if(rc != SQLITE_AUTH) {
			error_string = sqlite3_errmsg(dbconn);
		}

		// The stmt is set to NULL on error so no need to finalize here
		return NULL;
	}

	// Actually run the query and check for execution errors
	rc = sqlite3_step(stmt);
	if(rc != SQLITE_DONE && rc != SQLITE_ROW) {
		// Finalize the statement on error since its handle won't be returned
		sqlite3_finalize(stmt);
		error_string = sqlite3_errmsg(dbconn);
		return NULL;
	}

	// Add stmt handle to set of valid pointers and convert it to a string
	stmt_set.insert(stmt);
	std::ostringstream result;
	result << stmt;

	// Convert ostringstream to a persistant C string that can be returned
	error_string = NULL;
	result_string = result.str();
	return result_string.c_str();
}

// Finalize (or close) SQL statement previously created with dm_db_execute().
// All statements must be finalized before the database file itself can be
// closed.
//
// argc: Number of arguments passed in by BYOND script
// argv[0]: Statement handle to finalize; returned by previous dm_db_execute()
//
// Return: An empty "" string on success and NULL on error.
extern "C" const char *dm_db_finalize(int argc, char *argv[])
{
	// Decode the prepared statement handle from the first argument
	sqlite3_stmt *stmt;
	stmt = (sqlite3_stmt *) get_handle(argc, argv, 0, stmt_set, STMT);
	if(stmt == NULL) {
		return NULL;
	}

	// Finalize can only return previous error so ignote it here;
	sqlite3_finalize(stmt);

	// Remove handle from pointer set; return empty string indicating success
	stmt_set.erase(stmt);
	error_string = NULL;
	return "";
}

// Return the next row of data from a SQL statement previously created and
// started by dm_db_execute().
//
// argc: Number of arguments passed in by BYOND script
// argv[0]: Database handle in which the statement was executed
// argv[1]: Statement handle for which to retrieve the next row of data
//
// Return: An empty "" string to prepared statement has finished execution,
// either with no results or after a previous dm_db_next_row() call has
// already returned the last row of the result set. When returning actual
// result set data, the entire row is encoded into a single string as follows:
//
// Each column in encoded into the form "TN:D". The T is a single character
// designating the data type of this column. The N is an explicit length
// (encoded as an ASCII string) of the column data that follows. Finally the
// D is the column data itself. The colon (:) character serves to separate
// the length from the data in case the data itself is numeric. There are no
// other delimiters between individual columns in the result string, and the
// the explicit length makes it easy to parse result in a BYOND script.
//
// An integer or floating point column value is encoded as a simple ASCII
// string, similar to how the length itself is encoded. They respectively use
// the 'I' and 'F' type codes, and their length N is simply the length of the
// string that contains the numeric column value. An example result set with
// three columns might look like "I1:1F3:2.5I2:42"
//
// A TEXT column uses the 'T' type code, and the column data is output using
// UTF-8 encoding, with length N simply the length of the UTF-8 string. An
// example row with a combination of text and integer values might look like
// "T13:Hello, world!I2:42T7:foo:bar". Note that the colon (:) (or any other
// character) will not be escaped in any way.
//
// If any column contains a NULL, then its value is encoded as "N0:" with a
// zero length and the data portion missing.
//
// Finally, because BYOND DreamMaker scripts have no meaningful datatype which
// could represent binary data directly, BLOB column types are encoded as
// "B0:" with the data portion once again missing. In the future, the binary
// data could be encoded into hexadecimal or base64.
extern "C" const char *dm_db_next_row(int argc, char *argv[])
{
	// Decode the database handle from the first argument
	sqlite3 *dbconn;
	dbconn = (sqlite3 *) get_handle(argc, argv, 0, dbconn_set, DBCONN);
	if(dbconn == NULL) {
		return NULL;
	}

	// Decode the prepared statement handle from the second argument
	sqlite3_stmt *stmt;
	stmt = (sqlite3_stmt *) get_handle(argc, argv, 1, stmt_set, STMT);
	if(stmt == NULL) {
		return NULL;
	}

	// Check if statement has finished executing and has no more result data
	int rc = sqlite3_stmt_busy(stmt);
	if(!rc) {
		// Return empty string indicating successful execution of statement
		error_string = NULL;
		return "";
	}

	// Encode every column value in current result row into a string format
	std::ostringstream result;
	int columns = sqlite3_data_count(stmt);
	for(int index = 0; index < columns; index++) {

		// Emit a unique character code for each column data type
		int type = sqlite3_column_type(stmt, index);
		switch(type) {
			case SQLITE_INTEGER:
				result << 'I';
				break;
			case SQLITE_FLOAT:
				result << 'F';
				break;
			case SQLITE_TEXT:
				result << 'T';
				break;
			case SQLITE_BLOB:
				result << 'B';
				break;
			case SQLITE_NULL:
				result << 'N';
				break;

			// Unknown SQLite column type; should never happen
			default:
				error_string = "Unknown column data type in result";
				return NULL;
		}

		// The NULL and BLOB types return no data so emit a zero length for them
		if(type == SQLITE_BLOB || type == SQLITE_NULL) {
			result << "0:";
		}

		// Emit all other types as a string (SQLite will convert numeric types)
		else {
			// Must perform text conversion before obtaining byte count
			const unsigned char *text = sqlite3_column_text(stmt, index);
			int length = sqlite3_column_bytes(stmt, index);

			// Check for memory allocation failure in SQLite
			if(text == NULL) {
				error_string = "Out of memory";
				return NULL;
			}

			result << length << ':' << text;
		}
	}

	// Prepare the next row of result data for a future call to dm_db_next_row()
	rc = sqlite3_step(stmt);
	if(rc != SQLITE_DONE && rc != SQLITE_ROW) {
		// Return NULL to indicate error instead of current result row
		error_string = sqlite3_errmsg(dbconn);
		return NULL;
	}

	// Convert ostringstream to a persistant C string that can be returned
	error_string = NULL;
	result_string = result.str();
	return result_string.c_str();
}

// Return a list of the names assigned to each column in the result set of a
// statement previously started with dm_db_execute(). This will be either the
// name assigned in the statement with the "AS" clause, or the column's name
// from the table schema. Note that the SQLite library linked by this wrapper
// must have been compiled with the SQLITE_ENABLE_COLUMN_METADATA option for
// this function to work properly.
//
// argc: Number of arguments passed in by BYOND script
// argv[0]: Database handle in which the statement was executed
// argv[1]: Statement handle for which to retrieve the column names
//
// Return: A string with the list of column names encoded in exactly the same
// format as used by dm_db_next_row() to encode TEXT columns, or NULL if an
// error occurred.
extern "C" const char *dm_db_col_names(int argc, char *argv[])
{
	// Decode the database handle from the first argument
	sqlite3 *dbconn;
	dbconn = (sqlite3 *) get_handle(argc, argv, 0, dbconn_set, DBCONN);
	if(dbconn == NULL) {
		return NULL;
	}

	// Decode the prepared statement handle from the second argument
	sqlite3_stmt *stmt;
	stmt = (sqlite3_stmt *) get_handle(argc, argv, 1, stmt_set, STMT);
	if(stmt == NULL) {
		return NULL;
	}

	// Encode every result column name in the statement into a string format
	std::ostringstream result;
	int columns = sqlite3_data_count(stmt);
	for(int index = 0; index < columns; index++) {

		// Must perform text conversion before obtaining byte count
		const char *text = sqlite3_column_name(stmt, index);

		// Check for memory allocation failure in SQLite
		if(text == NULL) {
			error_string = "Out of memory";
			return NULL;
		}

		// Encode names in the same format text data in as dm_db_next_row()
		int length = strlen(text);
		result << 'T' << length << ':' << text;
	}

	// Convert ostringstream to a persistant C string that can be returned
	error_string = NULL;
	result_string = result.str();
	return result_string.c_str();
}

// Quote the string by escaping single quotes so that the string can be safely
// used as a literal value in a SQL statement. This prevents data injections
// attacks or just random incorrect behavior if the string happens to have an
// embedded quote (').
//
// argn: Number of arguments passed in by BYOND script
// argv[0]: The string to be escaped
//
// Return: The input string with ' replaced by '' or NULL on error.
extern "C" const char *dm_db_quote(int argc, char *argv[])
{
	// Check for usage: a single filename argument is required
	if(argc < 1) {
		error_string = "String argument is required";
		return NULL;
	}

	// Empty result string so it can accumulate the quoted string
	result_string.clear();

	// Repeatedly search the string for any occurance of single quote (') char
	char *match, *pos = argv[0];
	while((match = strchr(pos, '\''))) {

		// Append portion of input string up to but not including single quote
		result_string.append(pos, match - pos);

		// The single quote in original string is replaced with two quotes
		result_string.append("''");

		// The next char search must start at the next char after the quote
		pos = match + 1;
	}

	// If no more matches found, append remaining input string to result
	result_string.append(pos);

	// Convert the result to a C string and return
	error_string = NULL;
	return result_string.c_str();
}
