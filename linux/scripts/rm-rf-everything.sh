#extreme warning !! very destructive script!! test yourself before use!! i will NOT be responsible for any deleted files!!
#ALL AND EVERYTHING WILL BE REMOVED WITHOUT PROMPT AND UNSTOPPABLE !!!
#recommend to run it manually after extreme care look at the path you want to remove!!
#https://yonglhuang.com/rm-file/
#https://www.slashroot.in/which-is-the-fastest-method-to-delete-files-in-linux

if [ -z "$1" ]; then exit; fi
echo destroying $1 in 10 second !! ctrl+c to cancel now !!
sleep 10

cd $1 || exit #avoid mistakenly run script

rm -rf $1/*   &
ionice -c 3 rm -rf $1   &

#find $1/ -print0 | xargs -0 rm -rf   &
find $1 -exec rm {} +   &
find $1 -delete   &


perl -e 'for(<*>){unlink}'   &
perl -e 'for(<*>){((stat)[9]<(unlink))}'   &

mkdir /tmp/emptydir
rsync -a --delete /tmp/emptydir  $1   &
