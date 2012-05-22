#!/usr/bin/env python

# This script digs through daedalus.dme and code/.  For every file in code/,
# it determines whether or not it is included in daedalus.dme; if not, it
# prints a message to that effect.

# It is primarily meant for a one-and-done run to get rid of all of the
# unused source lying around the tree, but could obviously be used on a
# semi-regular basis to make sure we're not stranding source somewhere.

# Invoke from the root Daed directory:
#    python tools/find_unused_source_files.py

import subprocess
import sys

# Open the .dme; bail if unsuccessful.
try:
   dme = open("daedalus.dme", "r")
except:
   print("ERROR: Could not open daedalus.dme for reading.  Are you not running this from the root?")
   sys.exit(1)

# All right.  Read in all of the #includes.
include_list = []
for line in dme:
   line = line.strip()
   if((len(line) > 8) and (line[0:8] == "#include")):
      includefile_name = line.split('"')[1]

      # They're DOS-style, so make them UNIX-style.
      includefile_name = includefile_name.replace('\\', '/')
      include_list.append(includefile_name)

# Now get a list of all of the sourcefiles.
sourcefile_output = subprocess.check_output(["find", "code/", "-type", "f"]).decode("utf-8")
sourcefile_list = [x for x in sourcefile_output.split('\n') if len(x) > 0]

# Now, compare!  If there's something in the sourcefile list that isn't
# in the include list, it's not included.
for line in sorted(sourcefile_list):
   if line not in include_list:
      print("Unused source file: " + line)
