type_regex = /^\/?([a-zA-Z0-9_][a-zA-Z0-9_\/]*)/;

/* Comment blocks and file header are saved here temporarily so they can be later sent to another file */
saved_text = "";

/* If true, output to a file has begun and it's no longer necessary to save all input in saved_text */
output = 0;

state default
{
	/* Safety check to make sure input doesn't already contain the "here document" delimiter */
	/__END_OF_FILE__/    { panic("!!! SHELL CODE INJECTION DETECTED !!!"); }

	/\/\*/      { save($0); call(block_comment); }
	/\{\"/      { dump($0); call(block_string); }
	/\"/        { dump($0); call(inline_string); }
	/\/\//      { save($0); call(inline_comment); }
	/./         { dump($0); }

	/* Any filepath like definition at the start of a line begins a new file */
	type_regex {
		text = $0;
		type_name = $1;

		/* Safety check to make sure input doesn't already contain the "here document" delimiter */
		if(regmatch(text, /__END_OF_FILE__/)) {
			panic("!!! SHELL CODE INJECTION DETECTED !!!");
		}

		/* If file output has already started, terminate the previous shell "here document" */
		if(output) {
			print("__END_OF_FILE__\n");
		}
		output = 1;

		/* Isolate the typename and its base directory which will hold the output file */
		type_name = regsub(type_name, /\/(var|proc|verb).*($|\n)/, "");
		base_name = regsub(type_name, /\/[a-zA-Z0-9_]+($|\n)/, "");

		/* XXX TODO: Global vars/procs need to be send to their own special file (length(base_name) == 0) */

		/* Create destination directory and start a new shell "here document" that redirects to output file */
		print("mkdir -p code/", base_name, "\n");
		print("cat << __END_OF_FILE__ >> code/", type_name, ".dm\n");
		dump(text);
	}

	/* Triggered at the end of input to close the final "here document" if one is open */
	END {
		if(output) {
			print("__END_OF_FILE__\n");
		}
	}
}

state block_comment
{
	/* Safety check to make sure input doesn't already contain the "here document" delimiter */
	/__END_OF_FILE__/    { panic("!!! SHELL CODE INJECTION DETECTED !!!"); }

	/\*\/ *\r?\n?/  { save($0); return; }
	/./             { save($0); }
}

state inline_comment
{
	/* Safety check to make sure input doesn't already contain the "here document" delimiter */
	/__END_OF_FILE__/    { panic("!!! SHELL CODE INJECTION DETECTED !!!"); }

	/\n/    { save($0); return; }
	/./     { save($0); }
}

state block_string
{
	/* Safety check to make sure input doesn't already contain the "here document" delimiter */
	/__END_OF_FILE__/    { panic("!!! SHELL CODE INJECTION DETECTED !!!"); }

	/\\\"/  { dump($0); }
	/\"\}/  { dump($0); return; }
}

state inline_string
{
	/* Safety check to make sure input doesn't already contain the "here document" delimiter */
	/__END_OF_FILE__/    { panic("!!! SHELL CODE INJECTION DETECTED !!!"); }

	/\\\"/  { dump($0); }
	/\"/    { dump($0); return; }
}

sub save(text)
{
	saved_text = concat(saved_text, text);
}

sub dump(text)
{
	if(output) {
		print(saved_text, text);
		saved_text = "";
	} else {
		save(text);
	}
}