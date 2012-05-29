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

// TODO DELETE ME
#include <iostream>

#include <sstream>
#include <string>
#include <set>
#include "sqlite3.h"

typedef std::set<void *> pointer_set_t;

pointer_set_t dbconn_set;
pointer_set_t stmt_set;

/*
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
*/

// For safety purposes, this wrapper library never returns handles to the
// SQLite objects directly. Instead it returns an index into the array
// below which in turn maps it to the real connection/statement handle.
// Since global data is always initialized to NULL, this marks all handle_t
// array elements as being free.
//static handle_t handle_list[HANDLE_MAX];

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
static void *get_handle(int argc, char *argv[], int argn, const pointer_set_t &set)
{
	// Check for usage: a single filename argument is required
	if(argc < (argn + 1)) {
		error_string = "Database or query handle argument is required";
		return NULL;
	}

	// Convert the string argument into a numeric pointer value
	std::istringstream buffer(argv[argn]);
	void *pointer;
	buffer >> pointer;

	// Check if argument was parsable and is in the set of valid pointers
	if(buffer.fail() || set.find(pointer) == set.end()) {
		error_string = "Database or query handle argument is not valid";
		return NULL;
	}

	// Return the real open SQLite database handle if it was found
	return pointer;
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

	// Attempt to open a SQLite database and check for library errors
	sqlite3 *dbconn;
	int rc = sqlite3_open(argv[0], &dbconn);

	// If database cannot be opened, save error message and close handle
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

// Close a database connection previously opened with dm_db_open(). Takes the
// numeric index of the database connection (which was returnd by dm_db_open)
// as the single argument. Returns an empty "" string on success and NULL
// on error.
extern "C" const char *dm_db_close(int argc, char *argv[])
{
	// Decode the database handle from the first argument
	sqlite3 *dbconn = (sqlite3 *) get_handle(argc, argv, 0, dbconn_set);
	if(dbconn == NULL) {
		return NULL;
	}

	// Finalize any exisitng prepared statement the connection may still have
	sqlite3_stmt* stmt = sqlite3_next_stmt(dbconn, NULL);
	while(stmt != NULL) {
		sqlite3_stmt* prev = stmt;
		stmt = sqlite3_next_stmt(dbconn, stmt);

		// Finalize can only return previous statment error so ignore it here
		// TODO: Check returns here?
		if(sqlite3_finalize(prev) != SQLITE_OK) {
			std::cerr << "FINALIZE ERROR" << std::endl;
		}

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

extern "C" const char *dm_db_finalize(int argc, char *argv[])
{
	// Decode the prepared statement handle from the first argument
	sqlite3_stmt *stmt = (sqlite3_stmt *) get_handle(argc, argv, 0, stmt_set);
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

// Prepare a SQL statement for execution on a previously opened database
// connection. The statement is not actually executed until dm_db_step() is
// called. Returns an empty "" string on success and NULL on error.
extern "C" const char *dm_db_execute(int argc, char *argv[])
{
	// Decode the database handle from the first argument
	sqlite3 *dbconn = (sqlite3 *) get_handle(argc, argv, 0, dbconn_set);
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
		// The stmt is set to NULL on error so no need to finalize here
		error_string = sqlite3_errmsg(dbconn);
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
extern "C" const char *dm_db_next_row(int argc, char *argv[])
{
	// Decode the database handle from the first argument
	sqlite3 *dbconn = (sqlite3 *) get_handle(argc, argv, 0, dbconn_set);
	if(dbconn == NULL) {
		return NULL;
	}

	// Decode the prepared statement handle from the second argument
	sqlite3_stmt *stmt = (sqlite3_stmt *) get_handle(argc, argv, 1, stmt_set);
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
				result << 'X';
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
