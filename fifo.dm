// The fifo class and the dmfifo.so native code library can be used to 
// perform non-blocking writes to a FIFO special file under Linux.
// An ordinary blocking write, such as BYOND's text2file() proc, can 
// block the DreamDaemon indefinitely if no other process has the FIFO 
// open for reading. Doing a non-blocking write here guarantees that the 
// BYOND script continues to execute without blocking, even if the 
// message has to be discarded because the FIFO has no readers.
//
// The variables and procs that begin with an underscode (_) are intended
// for internal use only and may change in newer versions of this library.
fifo
	var
		// The name of the FIFO special file opened by this object.
		// Set by New() when the object is first created.
		_file_name

	// Create a new object associated with a given FIFO file.
	New(file_name)
		src._file_name = file_name
		return ..()

	proc
		// Write a text message to the FIFO special file. Returns 1 if the
		// entire message was successfully written, and 0 if any error has 
		// occurred (for example, the FIFO is not open for reading by any
		// other process).
		//
		// If the BYOND project is compiled in DEBUG mode, then an error
		// will call CRASH() and display both a stack trace and the error 
		// message to world.log.
		write(message)
			var/error = call("dmfifo.so", "dm_fifo_write")(_file_name, message)
			if(error)
#ifdef DEBUG
				. = 0
				CRASH(error)
#else
				return 0;
#endif
			return 1;
