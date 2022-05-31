#!/bin/sh
service rpcbind stop
service nfs-user-server stop
[ -n "$1" ] && sleep "$1"
#sleeps for specified time if argument given, otherwise restarts immediately
rpcbind -w
service nfs-user-server start