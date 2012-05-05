#!/bin/bash

#  This will dive through the entire source tree, and give you a list of all
#  files containing the speficied word.  It will perform a case-insentitive
#  search from $CWD.  It is adviseable to search from the root of the repo
#  directory tree (i. e. not within /code/).

if [[ 0 -eq $# ]]; then
   echo -e "Usage:\t$0 $HAYSTACK"
   exit 1
fi

grep -R "$*" * | cut -d ':' -f 1 | sort | uniq
