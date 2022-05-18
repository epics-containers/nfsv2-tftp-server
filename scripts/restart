#!/bin/sh
service rpcbind stop
bash /etc/init.d/nfs-user-server stop
[ ! -z "$1" ] && sleep $1
#sleeps for specified time if argument given, otherwise restarts immediately
rpcbind -w
bash /etc/init.d/nfs-user-server start