// Component Name: Non-blocking FIFO writing library for BYOND DreamMaker scripts
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

#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <sys/stat.h>

// Write a short text message to a FIFO pseudofile in non-blocking mode.
// An ordinary blocking write, such as BYOND's text2file() proc, can block
// the DreamDaemon indefinitely if no other process has the FIFO open for
// reading. Doing a non-blocking write here guarantees that the BYOND
// script continues to execute without blocking, even if the message has
// to be discarded because the FIFO has no readers.
//
// argc: Number of arguments passed in by BYOND script
// argv[0]: The text message to be sent
// argv[1]: The filename of the FIFO file; must already exist
//
// Return: NULL on success or an error message on failure.
const char *dm_text2fifo(int argc, const char *argv[])
{
	// Check for usage: a filename and text message argument is required
	if(argc < 2) {
		return "Text message and file path arguments required";
	}

	// BYOND always passes in a non NULL pointer for the arguments
	const char *message = argv[0];
	const char *file_path = argv[1];
	int length = strlen(message);

	// Do not allow absolute pathnames that start with a /
	if(file_path[0] == '/') {
		return "File path may not start with \"/\"";
	}

	// Split string along the / path separator for individual filename checks.
	// The name variable always points to the beginning of the next path
	// component (i.e. directory or filename) in the string, or points to the
	// terminating NULL character if the entire string has been searched.
	const char *name = file_path;
	while(*name) {
		// If / not found in string, then use remaining length of the string
		const char *next = strchr(name, '/');
		if(next == NULL) {
			next = file_path + strlen(file_path);
		}

		// Check for .. directory names that could escape the game directory
		if(strncmp(name, "..", next - name) == 0) {
			return "File path may not contain .. parent directory";
		}

		// Skip over the / separator to match the next component, unless this
		// was the last path component and next points to the terminating NULL.
		name = next;
		if(*name) {
			name++;
		}
	}

	// Open file for non-blocking write mode, but only if it already exists
	int fd = open(file_path, O_WRONLY | O_NONBLOCK);
	if(fd == -1) {
		return strerror(errno);
	}

	// Attempt writing the supplied text message string to the FIFO (without
	// writing the terminating NULL).
	int rc = write(fd, message, length);
	if(rc == -1) {
		close(fd);
		return strerror(errno);
	}

	// If the entire message cannot be written at once, then the FIFO buffer
	// must be full and part of the message was truncated. Return an error
	// message with no attempt made to write the truncated portion again.
	if(rc != length) {
		close(fd);
		return "Message truncated; FIFO has no readers or is full";
	}
	
	// Message write successfull; close the FIFO before returning to BYOND
	rc = close(fd);
	if(rc == -1) {
		return strerror(errno);
	}
	
	// Return NULL to indicate a successfull write of the entire message
	return NULL;
}
