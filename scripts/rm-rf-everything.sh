#extreme warning !!
#ALL AND EVERYTHING WILL BE REMOVED WITHOUT PROMPT!!!
#recommend to run it manually after extreme care look at the path you want to remove!!

cd /path/to/be/removed || exit #avoid mistakenly run script

mkdir /tmp/emptydir
rsync -a --delete /tmp/emptydir  .

perl -e 'for(<*>){unlink}'
perl -e 'for(<*>){((stat)[9]<(unlink))}'

ionice -c 3 rm *
