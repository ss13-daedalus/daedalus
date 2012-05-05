#!/bin/bash

#  This will dive through the entire source tree, and give you a list of all
#  files containing the speficied word.  It will perform a case-insentitive
#  search from $CWD.  It is adviseable to search from the root of the repo
#  directory tree (i. e. not within /code/).
#  It will also search for any file names or directory names matching the
#  the criteria given.

if [[ 0 -eq $# ]]; then
   echo -e "Usage:\t$0 $HAYSTACK"
   exit 1
fi

echo "Files containing '$*':"
grep -Ri "$*" * | cut -d ':' -f 1 | sort | uniq
echo "Filenames matching '$*':"
find ./ -name *"$*"*
