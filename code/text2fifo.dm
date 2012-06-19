// The fifo class and the dmfifo.so native code library can be used to 
// perform non-blocking writes to a FIFO special file under Linux.
// An ordinary blocking write, such as BYOND's text2file() proc, can 
// block the DreamDaemon indefinitely if no other process has the FIFO 
// open for reading. Doing a non-blocking write here guarantees that the 
// BYOND script continues to execute without blocking, even if the 
// message has to be discarded because the FIFO has no readers.
//
// Write a text message to the FIFO special file. Returns 1 if the
// entire message was successfully written, and 0 if any error has 
// occurred (for example, the FIFO is not open for reading by any
// other process).
//
// If the BYOND project is compiled in DEBUG mode, then an error
// will call CRASH() and display both a stack trace and the error 
// message to world.log.
/proc/text2fifo(message, file_name)
	var/error = call("dmfifo.so", "dm_text2fifo")(message, file_name)
	if(error)
#ifdef DEBUG
		. = 0
		CRASH(error)
#else
		return 0;
#endif
	return 1;
