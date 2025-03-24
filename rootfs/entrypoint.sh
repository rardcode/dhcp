#!/bin/bash
set -x

: ${path_list:="
/path/foo
"}

function _dirs {
DEST_PATH="/data"

echo "--------------------------------------"
echo " Moving persistent data in $DEST_PATH "
echo "--------------------------------------"

for path_name in $path_list; do
 if [ ! -e ${DEST_PATH}${path_name} ]; then
  if [ -d $path_name ]; then
   rsync -Ra ${path_name}/ ${DEST_PATH}/
  else
   rsync -Ra ${path_name} ${DEST_PATH}/
  fi
 else
  echo "---------------------------------------------------------"
  echo " No NEED to move anything for $path_name in ${DEST_PATH} "
  echo "---------------------------------------------------------"
 fi
rm -rf ${path_name}
ln -s ${DEST_PATH}${path_name} ${path_name}
done
}

function _main {
 [ -e "/data/dhcpd4.conf" ] || cp "/tmp/dhcpd4.conf" "/data/"
 [ -e "/data/dhcpd6.conf" ] || cp "/tmp/dhcpd6.conf" "/data/"
 [ -e "/data/dhcpd4.leases" ] || touch "/data/dhcpd4.leases"
 [ -e "/data/dhcpd6.leases" ] || touch "/data/dhcpd6.leases"
 useradd dhcpd
 uid=$(id -u dhcpd)
 gid=$(id -g dhcpd)
 chown -R dhcpd: "/data/dhcpd4.leases" "/data/dhcpd6.leases"

 export CMDv4="/usr/sbin/dhcpd -4 -f -d --no-pid -cf /data/dhcpd4.conf -lf /data/dhcpd4.leases -user dhcpd -group dhcpd"
 export CMDv6="/usr/sbin/dhcpd -6 -f -d --no-pid -cf /data/dhcpd6.conf -lf /data/dhcpd6.leases -user dhcpd -group dhcpd"

 [ "$DHCP4" = "1" ] && export CMD=$CMDv4
 if [ "$DHCP6" = "1" ]; then
  [ -z "$CMD" ] && export CMD=$CMDv6 || $CMDv6 &
 fi
chown -R dhcpd: "/data"
}

function custom_bashrc {
echo '
export LS_OPTIONS="--color=auto"
alias "ls=ls $LS_OPTIONS"
alias "ll=ls $LS_OPTIONS -la"
alias "l=ls $LS_OPTIONS -lA"
'
}

function _bashrc {
echo "-----------------------------------------"
echo " .bashrc file setup..."
echo "-----------------------------------------"
custom_bashrc | tee /root/.bashrc
echo 'export PS1="\[\e[35m\][\[\e[31m\]\u\[\e[36m\]@\[\e[32m\]\h\[\e[90m\] \w\[\e[35m\]]\[\e[0m\]# "' >> /root/.bashrc
for i in $(ls /home); do echo 'export PS1="\[\e[35m\][\[\e[33m\]\u\[\e[36m\]@\[\e[32m\]\h\[\e[90m\] \w\[\e[35m\]]\[\e[0m\]$ "' >> /home/${i}/.bashrc; done
}

#_dirs
_main
_bashrc

#CMD="$@"
[ -z "$CMD" ] && export CMD="supervisord -c /etc/supervisor/supervisord.conf"

exec $CMD

exit $?
