// The SQLiteDB class interfaces to the SQLite library. A separate SQLiteDB
// object should be created for each database file that the application
// intends to use.
SQLiteDB
	var
		// The platform dependant name of the SQLite wrapper library. The
		// first SQLiteDB object will initialize this to either "dmsqlite.dll"
		// on Windows or "dmsqlite.so" on Linux and Mac OSX.
		global/_native_lib

		// The name of the SQLite database file opened by this SQLiteDB.
		// Set by New() and used as a default if no file name is passed to the
		// Connect() procedure, and set by Connect() if a new filename is
		// passed in.
		_file_name

		// Handle for the current SQLite database. Returned by dm_db_open()
		// and passed as the first argument to most other dm_db_xxx() methods
		// in the dmsqlite native code library.
		_handle

	// Create a new SQLiteDB object for a specified database file. Note that
	// the database is not actually opened until the Connect() proc is called.
	New(file_name)
		// The first SQLiteDB object initializes platform specific name of the
		// native code SQLite wrapper library
		if(_native_lib == null)
			if(world.system_type == MS_WINDOWS)
				src._native_lib = "dmsqlite.dll"
			else
				src._native_lib = "dmsqlite.so"

		// Set default file name for this SQLiteDB for use in Connect()
		src._file_name = file_name
		return ..()

	// Close the database file when deleting the SQLiteDB object to avoid any
	// resource leaks.
	Del()
		if(_handle)
			Disconnect()
		..()

	proc
		// Open the database file using either the name passed in as an 
		// argument to Connect() or the name previously passed in to New().
		// Returns 0 on error and 1 on success.
		Connect(file_name=_file_name)
			src._file_name=file_name
			src._handle = call(_native_lib, "dm_db_open")(_file_name)
			if(_handle == null)
				_log_error()
			return (_handle == null) ? 0 : 1;

		// Close the database file that was previously opened with Connect()
		// Any open queries for this database connection are automatically
		// closed as well. Returns 0 on error and 1 on success.
		Disconnect()
			src._handle = call(_native_lib, "dm_db_close")(_handle)
			if(_handle == null)
				_log_error()
			return (_handle == null) ? 0 : 1;

		// Return 1 if this SQLiteDB has a database file open from a previous
		// call to Connect(), and return 0 otherwise.
		IsConnected()
			// The _handle is null or an empty string when file not open
			return (_handle) ? 1 : 0;

		// Quote the string by escaping single quotes so that the string
		// can be safely used as a literal value in a SQL statement. This
		// prevents data injections attacks or just random incorrect
		// behavior if the string happens to have an embedded quote (').
		Quote(str)
			return call(_native_lib, "dm_db_quote")(str)

		// If any operation on this database file returned 0 due to an error,
		// this proc can be called to return a description of that error.
		// However, if the last operation on this database file succeeded and
		// returned a 1, then the result of this proc is undefined.
		ErrorMsg()
			return call(_native_lib, "dm_db_error_msg")(_handle)

		// A convenience proc to quickly switch the database file in use by
		// first closing the existing file (if it is currently open) and then
		// opening a new file. Return 0 on error in either the close or open
		// operations, and 1 if both operations succeeded.
		SelectDB(file_name)
			if(_handle)
				if(!Disconnect())
					return 0;
			return Connect(file_name)

		// Create a new SQLiteQuery object associated with this database file.
		// The query passed in will be the default if another query is not
		// passed to the Execute() proc in the SQLiteQuery object.
		NewQuery(sql)
			return new/SQLiteDB/SQLiteQuery(sql,src)

		// This proc is called if SQLite reports any kind of error. If DEBUG
		// is defined, the proc will rerieve the error from the wrapper
		// library and will send it to world.log. If DEBUG is not defined,
		// this method does nothing.
		_log_error()
			world.log << "ERROR"
			world.log << call(_native_lib, "dm_db_error_msg")(_handle)

	// This class encapsulates a single SQL query along with any result data
	// produced by that query. Instances of this class should be created using the
	// NewQuery() proc in SQLiteDB rather than directly by the user.
	SQLiteQuery
		var
			// The default SQL query set by NewQuery() and used if no other
			// query is passed to Execute().
			sql

			// List containing the column values from the current row of results.
			// Each call to NextRow() will allocate a new list to hold the column
			// values for that row.
			list/item[0]
			
			// Handle to prepared statement created by sqlite3_prepare_v2() in
			// the native wrapper library.
			_stmt

		// Copy the internal fields from parent object when this SQLiteQuery
		// is created by the parent object with NewQuery().
		New(sql,SQLiteDB/dbconn)
			src.sql = sql
			src._file_name = dbconn._file_name
			src._handle = dbconn._handle
			return ..()

		// Delete the query from the native wrapper library when this object
		// gets deleted to avoid any resource leaks.
		Del()
			Close()

			// Don't let inherited Del() delete the database handle. Only the
			// original SQLiteDB object should do that.
			_handle = null
			..()

		proc
			// Execute the specified query and returns 1 if the query
			// succeeded or 0 if an error occurred during the query's
			// execution. If no query is specified then use the default
			// query set by NewQuery().
			Execute(sql=src.sql)
				// Close existing statement to avoid resource leaks
				Close()

				// Execute the SQL statement and save handle for later
				src._stmt = call(_native_lib, "dm_db_execute")(_handle, sql)
				if(_stmt == null)
					_log_error()
					return 0

				// Return 1 if the statement has executed successfully
				return 1

			NextRow()
				// Allocate new list to hold column data of the next row
				src.item = new/list

				// Call sqlite3_step() to obtain the next row of results
				var/result = call(_native_lib, "dm_db_next_row")(_handle, _stmt)
				if(result == null)
					_log_error()
					return 0

				// Need at least two characters in the _result buffer to
				// begin parsing: type code and at least one length digit
				while(result)
					// Single character type code for this column
					var/type = copytext(result, 1, 2)

					// Length of the data in this column
					var/len = text2num(copytext(result, 2))

					// Column data starts immediately after the ":"
					var/pos = findtext(result, ":")
					var/col = copytext(result, pos + 1, pos + 1 + len)

					// Parse the column data based on its type code
					if(type == "I" || type == "F")
						src.item += text2num(col)
					else if(type == "T")
						src.item += col
					else
						src.item += null

					// Shift remaining text to the left for next column
					result = copytext(result, pos + 1 + len)

				// Return true if a new data row is available
				return (src.item.len) ? 1 : 0;				
/*
			RowsAffected() return _dm_db_rows_affected(_db_query)

			GetRowData()
				var/list/columns = Columns()
				var/list/results
				if(columns.len)
					results = list()
					for(var/C in columns)
						results+=C
						var/DBColumn/cur_col = columns[C]
						results[C] = src.item[(cur_col.position+1)]
				return results
*/
			// Close the currently executing query if one exists. This proc
			// does not have to be called manually since both Execute() and
			// Del() will call it automatically as needed. This proc always
			// succeeds and doesn't return any status indicator.
			Close()
				src.item.len = 0
				if(_stmt)
					call(_native_lib, "dm_db_finalize")(_stmt)
					_stmt = null
