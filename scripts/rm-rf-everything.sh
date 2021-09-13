#extreme warning !! test before use!! i will NOT be responsible for any deleted files!!
#ALL AND EVERYTHING WILL BE REMOVED WITHOUT PROMPT!!!
#recommend to run it manually after extreme care look at the path you want to remove!!

if [ -n "$1" ]; then exit; fi
cd $1 || exit #avoid mistakenly run script

mkdir /tmp/emptydir
rsync -a --delete /tmp/emptydir  $1   &

perl -e 'for(<*>){unlink}'   &
perl -e 'for(<*>){((stat)[9]<(unlink))}'   &

ionice -c 3 rm -rf $1   &

find $1 -delete   &
