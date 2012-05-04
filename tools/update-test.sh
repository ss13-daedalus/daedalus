#!/bin/bash
DMEFILE=baystation12.dme

if [[ 0 -eq $# ]]; then
   echo "Please run the $0 with the correct paramaters:"
   echo -e "\t$0 [ beta | stable ]"
   exit 0
else
   case $1 in
      "beta")
         MODE=beta
         ;;
      "stable")
         MODE=stable
         ;;
      *)
         echo "Mode $0 not known.  Please use the following syntax:"
         echo -e "\t$0 [ beta | stable ]"
         exit 0
         ;;
   esac
   BYOND=/home/ghoti/byond/$MODE/byond/
fi

echo "Copying source from git repository.."
rsync -zah --stats --delete /home/ghoti/src/daedalus/ /home/ghoti/byond/daedalus-src/
echo $MODE > /home/ghoti/byond/daedalus-test/mode

echo "Setting up build environment.."
source $BYOND/bin/byondsetup
echo "Building BYOND world.."
DreamMaker /home/ghoti/byond/daedalus-src/$DMEFILE
