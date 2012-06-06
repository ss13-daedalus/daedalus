// If the BYOND project is compiled in DEBUG mode, then any SQLite error
// will call CRASH() and display both a stack trace and the error message
// to world.log. Otherwise, database errors are silent and have to be
// checked for by the caller of the various procs defined here.
#ifdef DEBUG
#define RETURN_ERROR(i) . = (i); CRASH(_error)
#else
#define RETURN_ERROR(i) return (i)
#endif

// The SQLite class interfaces to the SQLite library. A separate SQLite
// object should be created for each database file that the application
// intends to use.
//
// The variables and procs that begin with an underscode (_) are intended
// for internal use only and may change in newer versions of this library.
SQLite
	var
		// The platform dependant name of the SQLite wrapper library. The
		// first SQLite object will initialize this to either "dmsqlite.dll"
		// on Windows or "dmsqlite.so" on Linux and Mac OSX.
		global/_native_lib

		// The name of the SQLite database file opened by this SQLite object.
		// Set by New() and used as a default if no file name is passed to the
		// Connect() procedure.
		_file_name

		// Handle for the current SQLite database. Returned by dm_db_open()
		// and passed as the first argument to most other dm_db_xxx() methods
		// in the dmsqlite native code library.
		_handle

		// Error message for the last error tha
		_error

	// Create a new SQLite object for a specified database file. Note that
	// the database is not actually opened until the Connect() proc is called.
	New(file_name)
		// The first SQLite object initializes platform specific name of the
		// native code SQLite wrapper library
		if(_native_lib == null)
			if(world.system_type == MS_WINDOWS)
				src._native_lib = "dmsqlite.dll"
			else
				src._native_lib = "dmsqlite.so"

		// Set default file name for this SQLite object for use in Connect()
		src._file_name = file_name
		return ..()

	// Close the database file when deleting the SQLite object to avoid any
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
			src._handle = call(_native_lib, "dm_db_open")(file_name)
			if(_handle == null)
				_log_error()
				RETURN_ERROR(0)
			return 1;

		// Close the database file that was previously opened with Connect()
		// Any open queries for this database connection are automatically
		// closed as well. Returns 0 on error and 1 on success.
		Disconnect()
			src._handle = call(_native_lib, "dm_db_close")(_handle)
			if(_handle == null)
				_log_error()
				RETURN_ERROR(0)
			return 1;

		// Return 1 if this SQLite object has a database file open from a
		// previous call to Connect(), and return 0 otherwise.
		IsConnected()
			// The _handle is null or an empty string when file not open
			return (_handle) ? 1 : 0;

		// Quote the string by escaping single quotes so that the string
		// can be safely used as a literal value in a SQL statement. This
		// prevents data injections attacks or just random incorrect
		// behavior if the string happens to have an embedded quote (').
		// Returns null if an error occurs.
		Quote(str)
			str = call(_native_lib, "dm_db_quote")(str)
			if(str == null)
				_log_error()
				RETURN_ERROR(null)
			return str

		// If any operation on this database file returned 0 due to an error,
		// this proc can be called to return a description of that error.
		// However, if the last operation on this database file succeeded and
		// returned a 1, then the result of this proc is undefined.
		ErrorMsg()
			return _error

		// A convenience proc to quickly switch the database file in use by
		// first closing the existing file (if it is currently open) and then
		// opening a new file. Return 0 on error in either the close or open
		// operations, and 1 if both operations succeeded.
		SelectDB(file_name)
			if(_handle)
				if(!Disconnect())
					return 0;
			return Connect(file_name)

		// Create a new Query object associated with this database file.
		// The query passed in will be the default if another query is not
		// passed to the Execute() proc in the Query object.
		NewQuery(sql)
			return new/SQLite/Query(sql,src)

		// This proc is called if SQLite reports any kind of error. It obtains
		// the error message from the native wrapper library and saves it
		// in the _error variable for later retrieval by ErrorMsg()
		_log_error()
			src._error = call(_native_lib, "dm_db_error_msg")()

	// This class encapsulates a single SQL query along with any result data
	// produced by that query. Instances of this class should be created using the
	// NewQuery() proc in the SQLite class rather than directly by the user. A single
	// query object can be used multiple times to execute different queries.
	Query
		var
			// The default SQL query set by NewQuery() and used if no other
			// query is passed to Execute().
			sql

			// List containing the column values from the current row of results.
			// Each call to NextRow() will allocate a new list to hold the column
			// values for that row.
			list/item

			// Handle to prepared statement created by sqlite3_prepare_v2() in
			// the native wrapper library.
			_stmt

			// A list of column names obtained by the first call to GetRowData()
			_names

		// Copy the internal fields from parent object when this Query
		// is created by the parent object with NewQuery().
		New(sql,SQLite/dbconn)
			src.sql = sql
			src._file_name = dbconn._file_name
			src._handle = dbconn._handle
			return ..()

		// Delete the query from the native wrapper library when this object
		// gets deleted to avoid any resource leaks.
		Del()
			Close()

			// Don't let inherited Del() delete the database handle. Only the
			// original SQLite object should do that.
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
					RETURN_ERROR(0)
				return 1

			// Obtain the next for of column data for a running query. If
			// more data is available, return and set the item var to a new
			// list containing the column data. If the SQL query finished
			// and has no more data, return 0 and set item var to a zero
			// length list. If an error occurs, return 0 and set item to null.
			NextRow()
				// Set item to null in case any error occurs
				src.item = null

				// Call sqlite3_step() to obtain the next row of results
				var/data = call(_native_lib, "dm_db_next_row")(_handle, _stmt)
				if(data == null)
					_log_error()
					RETURN_ERROR(0)

				// Decode the column data into item list
				src.item = _split(data)

				// Return true if a new data row is available
				return (src.item.len) ? 1 : 0;

			// Return an associative list containing the column data from the
			// last result row, indexed by the names of each column. This proc
			// must be called only after NextRow() returned a 1 to indicate more
			// data was available.
			GetRowData()
				// First call to GetRowData() must obtain column names
				if(_names == null)
					var/data = call(_native_lib, "dm_db_col_names")(_handle, _stmt)
					if(data == null)
						_log_error()
						RETURN_ERROR(null)

					// Split encoded column names into a proper list
					src._names = _split(data)

				// Allocate new output list for returning row data
				var/result = new/list

				// Make associative list of column data indexed by column name.
				// The names list is in the same column order as item list.
				var/index = 1
				for(var/col in _names)
					result += col
					result[col] = item[index]
					index++

				return result

			// Close the currently executing query if one exists. This proc
			// does not have to be called manually since both Execute() and
			// Del() will call it automatically as needed. This proc always
			// succeeds and return 1.
			Close()
				src.item = null
				src._names = null
				if(_stmt)
					call(_native_lib, "dm_db_finalize")(_stmt)
					src._stmt = null

			// Separate individual column data from a single encoded string
			// and return them as a list. Also perform type conversion on
			// columns with a numeric data type. See the native wrapper library
			// dmsqlite.cpp for the exact format of the data encoding.
			_split(row)
				// Allocate new list to hold the decoded column data
				var/list/result = new/list

				// Each iteration decodes the first column in the remaining
				// string and then shifts the string to the next column.
				while(row)
					// Single character type code for this column
					var/type = copytext(row, 1, 2)

					// Length of the data in this column
					var/len = text2num(copytext(row, 2))

					// Column data starts immediately after the ":"
					var/pos = findtext(row, ":")
					var/col = copytext(row, pos + 1, pos + 1 + len)

					// Parse the column data based on its type code
					if(type == "I" || type == "F")
						result += text2num(col)
					else if(type == "T")
						result += col
					else
						result += null

					// Shift remaining text to the left for next column
					row = copytext(row, pos + 1 + len)

				return result

#undef RETURN_ERROR
