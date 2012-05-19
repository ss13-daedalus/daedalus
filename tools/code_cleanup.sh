#!/bin/bash

# This is a script that automatically runs the "states" program with the
# "tools/code_cleanup.st" on all *.dm files within a particular code
# directory.
#
# The output of the cleanup script is then saved into a temporary file, and
# the user is given a diff between the original input .dm file and the
# generated output script. After viewing this diff, the user can then
# accept the changes as is, open an editor to make manual changes in the
# output script, or simply skip over the input file with the intention of
# coming back to manually fix it later.
#
# The only thing this script does not do is run "git add" on the updated or
# newly created files as part of the cleanup, nor does it run

# Environment variables specify the default editor and diff
diff=${DIFF:-sdiff}
editor=${EDITOR:-vim}

# Name of temporary putput shell script produced by code_cleanup.st
temp=code_cleanup.tmp

if [[ 0 -eq $# ]]; then
   echo "Please run $0 with the correct paramaters:"
   echo -e "\t$0 code/dir"
   exit 0
fi

find "$1" -name '*.dm' | (
   while read; do
      file="$REPLY"

      # Apply code cleanup and let user review the results via a diff
      states -s default -f tools/code_cleanup.st < "$REPLY" > "$temp"
      "$diff" "$file" "$temp"

      # Prompt user for action on the tty since stdin has the file list on it
      while true; do
         echo "$file"
         echo -n "Enter (y)es to apply, (n)o to skip, (d)iff again, (e)dit, (q)uit: "
         read < /dev/tty
         echo

         case "$REPLY" in
            "Y" | "y")
               sh "$temp"
               break
               ;;
            "N" | "n")
               break
               ;;
            "D" | "d")
               "$diff" "$file" "$temp"
               ;;
            "E" | "e")
               "$editor" "$temp"
               ;;
            "Q" | "q")
               exit 0
               ;;
         esac
      done
   done
)

# Cleanup temporary files when exiting script
trap 'rm "$temp"' EXIT
