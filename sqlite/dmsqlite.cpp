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
#include "sqlite3.h"

// The maximum number of concurrently open SQLite database connections
// that are supported by this wrapper library. This limit is just an
// arbitrary number to limit memory usage.
#define HANDLE_MAX 256

// Used in handle_list to track open connections and running SQL statements
typedef struct {
	// The database connection handle returned by sqlite3_open() or NULL if
	// this entry is not currently in use.
	sqlite3 *dbconn;

	// Prepared statement currently executing for this connection. This
	// wrapper library allows each DB conneciton to have only one
	// prepared SQL statement at a time. Set to NULL on initial database
	// connection, and when a prepared statement has been finilized after
	// returning its final result row.
	sqlite3_stmt* stmt;
} handle_t;

// For safety purposes, this wrapper library never returns handles to the
// SQLite objects directly. Instead it returns an index into the array
// below which in turn maps it to the real connection/statement handle.
// Since global data is always initialized to NULL, this marks all handle_t
// array elements as being free.
static handle_t handle_list[HANDLE_MAX];

// A placeholder for the last result string returned to the BYOND server
// by one of the dm_db_xxx() methods. This ensures the returned char pointer
// remains valid until the next dm_db_xxx() call.
static std::string result_string;

// If any error has occurred during the execution of a dm_db_xxx() method,
// this pointer will hold a reference to error message which can be
// later retrieved by dm_db_error_msg(). If the last dm_xxx() method produced
// no error, then this variable will be set to NULL.
static const char *error_string = NULL;

// Helper function to decode the database index passed as the first arguemnt
// to most dm_db_xxx() methods. If the handle index is valid and its associated
// database connection is open, then returns the index as an integer. If the
// index is invalid, then returns a -1.
int get_handle(int argc, char *argv[])
{
	// Check for usage: a single filename argument is required
	if(argc < 1) {
		error_string = "Database handle is required in 1st argument";
		return -1;
	}

	// Convert the string argument into a numeric handle
	std::istringstream handle(argv[0]);
	int index;
	handle >> index;

	// Check if the argument was parsable as a valid integer
	if(handle.fail()) {
		error_string = "Database handle argument is not an integer";
		return -1;
	}

	// Check if the index is out of range
	if(index < 0 || index >= HANDLE_MAX) {
		error_string = "Database handle argument is not a valid handle";
		return -1;
	}

	// Check if the database connection is open */
	if(handle_list[index].dbconn == NULL) {
		error_string = "Database handle is not currently open";
		return -1;
	}
	
	// Return the real open SQLite database handle if it was found
	return index;
}

// Return a human readable message if the last call to one of the dm_db_xxx()
// methods failed. If the last operation caused no errors, then returns
// NULL.
extern "C" const char *dm_db_error_msg(int argc, char *argv[])
{
	return error_string;
}

// Open a new database connection to the filename specified in argv[0]. If
// the connection is successful, returns a string encoded integer index into
// the handle_list which holds the handle to this connection. Returns NULL
// if an error occured.
extern "C" const char *dm_db_open(int argc, char *argv[])
{
	// Check for usage: a single filename argument is required
	if(argc < 1) {
		error_string = "Database filename is required as 1st argument";
		return NULL;
	}

	// Search the handle_list for the lowest free index (dbconn == NULL)
	int index;
	for(index = 0; index < HANDLE_MAX; index++) {
		if(handle_list[index].dbconn == NULL) {
			break;
		}
	}
	
	// Check if the maximum number of database connections is already open
	if(index == HANDLE_MAX) {
		error_string = "Maximum database connection limit reached";
		return NULL;
	}

	// Attempt to open a SQLite database and check for library errors
	sqlite3 *dbconn;
	int rc = sqlite3_open(argv[0], &dbconn);

	// If database cannot be opened, save error message and close handle
	if(rc != SQLITE_OK) {
		error_string = sqlite3_errmsg(dbconn);
		sqlite3_close(dbconn);
		return NULL;
	}

	// Connection succeeded so store then handle and convert index to string
	handle_list[index].dbconn = dbconn;
	std::ostringstream result;
	result << index;

	// Convert ostringstream to a persistant C string that can be returned
	error_string = NULL;
	result_string = result.str();
	return result_string.c_str();
}

// Close a database connection previously opened with dm_db_open(). Takes the
// numeric index of the database connection (which was returnd by dm_db_open)
// as the single argument. Returns an empty "" string on success and NULL
// on error.
extern "C" const char *dm_db_close(int argc, char *argv[])
{
	// Decode the database handle from the first argument
	int index = get_handle(argc, argv);
	if(index == -1) {
		return NULL;
	}
	handle_t *handle = &handle_list[index];

	// Finalize any exisitng prepared statement the connection may still have
	if(handle->stmt != NULL) {
		// Finalize can only return previous statment error so ignore it here
		sqlite3_finalize(handle->stmt);
		handle->stmt = NULL;
	}

	// Close the database itself and check for any errors on close
	int rc = sqlite3_close(handle->dbconn);
	if(rc != SQLITE_OK) {
		error_string = sqlite3_errmsg(handle->dbconn);
		return NULL;
	}

	// Free entry in handle_list and return empty string to indicate success
	error_string = NULL;
	handle->dbconn = NULL;
	return "";
}

// Prepare a SQL statement for execution on a previously opened database
// connection. The statement is not actually executed until dm_db_step() is
// called. Returns an empty "" string on success and NULL on error.
extern "C" const char *dm_db_prepare(int argc, char *argv[])
{
	// Decode the database handle from the first argument
	int index = get_handle(argc, argv);
	if(index == -1) {
		return NULL;
	}
	handle_t *handle = &handle_list[index];

	// Check that a second argument was passed in with the SQL string
	if(argc < 2) {
		error_string = "SQL statement is required as 2nd argument";
		return NULL;
	}

	// Finalize any exisitng prepared statement the connection may still have
	if(handle->stmt != NULL) {
		// Finalize can only return previous statment error so ignore it here
		sqlite3_finalize(handle->stmt);
		handle->stmt = NULL;
	}

	// Compile the SQL statement, check for errors, and save its handle
	int rc = sqlite3_prepare_v2(handle->dbconn, argv[1], -1, &handle->stmt, NULL);
	if(rc != SQLITE_OK) {
		error_string = sqlite3_errmsg(handle->dbconn);
		return NULL;
	}
	
	// Return empty string to indicate success
	error_string = NULL;
	return "";
}

// Execute the SQL statement previously prepared on this database connection
// and return the first row in its result set. Alternately, if the statement
// has already been executed with a dm_db_step() call, return the next row
// in its result set. Returns NULL when an error occurs. Returns an empty ""
// string to indicate the prepared statement has finished execution, either
// with no results or after a previous dm_db_step() call has already returned
// the last row of the result set. When returning an actual row in the result
// set, the entire row is encoded into a single string as follows:
//
// A comman character "," is appended after every column value in the string,
// including the last, to ensure that NULL column values can be encoded
// unambiguously (see below).
//
// An integer or floating point column value is encoded as a simple ASCII
// string plus the aforementioned comma. An example result set with three
// columns might look like "1,2.5,3,"
//
// A TEXT column is encoded as a "netstring". In other words, an explicit
// string length (using ASCII digits) and a colon ":" character are prepended
// to the actual string value. Note that the string contents are *not* escaped
// in any way and may contain a comma, colon, space, or any other character
// short of a '\0' byte. Therefore it is not safe to simply split the string
// returned by this function on every comma "," character; it must be parsed
// left to right. An example row with three columns and a combination of text
// and integer values might look like "13:Hello, world!,42,3:foo,". Notice
// that in the previous example, the string contents 
//
// If any column contains a NULL, its value is simply encoded as an empty
// string between the separating comma "," characters. For example, a NULL in
// the first and last column of this 4 column result set would look like
// ",1,2,,".
//
// Because BYOND DreamMaker scripts have no meaningful datatype which could
// represent binary data directly, the "X" character is returned as a place
// holder for any columns with a binary BLOB data type, as in "1,X,2,". In
// the future, the biaray data could be returned using the SQL hexadecimal
// literal syntax.
extern "C" const char *dm_db_step(int argc, char *argv[])
{
	// Decode the database handle from the first argument
	int index = get_handle(argc, argv);
	if(index == -1) {
		return NULL;
	}
	handle_t *handle = &handle_list[index];

	// Check if a SQL statement was prepared with dm_db_prepare()
	if(handle->stmt == NULL) {
		error_string = "No SQL statement has been prepared";
		return NULL;
	}

	// Obtain next row and finalize statement if completed with no more data
	int rc = sqlite3_step(handle->stmt);
	if(rc == SQLITE_DONE) {
		// Finalize can only return previous statment error so ignore it here
		sqlite3_finalize(handle->stmt);
		handle->stmt = NULL;
		error_string = NULL;
		return "";
	}

	// Check for execution errors and return without finalizing on error
	if(rc != SQLITE_ROW) {
		error_string = sqlite3_errmsg(handle->dbconn);
		return NULL;
	}

	// Encode every column value in the row into a string format
	std::ostringstream result;
	int columns = sqlite3_data_count(handle->stmt);
	for(index = 0; index < columns; index++) {
		// Convert each column value to a string based on its underlying type
		int type = sqlite3_column_type(handle->stmt, index);
		switch(type) {
			// Let SQLite convert any numeric type to a string
			case SQLITE_INTEGER:
			case SQLITE_FLOAT:
				result << sqlite3_column_text(handle->stmt, index);
				break;

			// Convert TEXT values to netstring form with explicit length
			case SQLITE_TEXT: {
				// Must convert text is in UTF-8 before obtaining length
				const unsigned char *text;
				text = sqlite3_column_text(handle->stmt, index);

				// SQLite's byte count does not include terminating NULL
				int bytes = sqlite3_column_bytes(handle->stmt, index);
				result << bytes << ':' << text;
				break;
			}

			// Binary BLOBs are not supported so return dummy "X" placeholder
			case SQLITE_BLOB:
				result << 'X';
				break;

			// Output nothing for a NULL column value
			case SQLITE_NULL:
				break;

			// Unknown SQLite column type; should never happen
			default:
				error_string = "Unknown column data type in result";
				return NULL;
		}

		// Append the required comma "," to separate columns from each other
		result << ',';
	}

	// Convert ostringstream to a persistant C string that can be returned
	error_string = NULL;
	result_string = result.str();
	return result_string.c_str();
}
