#dennyhalim.com log all bash console and ssh command
# mkdir -p /var/log/console
# chmod a+rwx /var/log/console
# mv consolelogging.sh /etc/profile.d/

_TGL=$(date +%F-%T)
HISTFILESIZE=10000
HISTFILE=/var/log/console/$USER-$_TGL
SSHFILE=/var/log/console/$USER-ssh-$_TGL
export HISTFILE SSHFILE
ssh () { /usr/bin/ssh "$@" | tee -a $SSHFILE ; }
