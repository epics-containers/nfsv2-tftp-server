#!/bin/bash

usage () {
  echo "Usage: addexport.sh <permissions> <export path> <client IP>
  Adds entry to /etc/exports, deleting existing entries pointing to the same path."
}


permissions="$1"
exportpath="$2"
exportpath_escaped=`echo "$exportpath" | sed 's/\//\\\\\//g'`
clientip="$3"

if [ -z "$exportpath" ]; 
then echo "Error: not enough arguments."; usage; exit 1
fi

if ! [ "$permissions" = "rw" ] && ! [ "$permissions" = "ro" ];
then echo "Error: $1 is not a recognised permissions option, use rw or ro"; usage; exit 1
fi

if ! [ -d "$exportpath" ];
then echo "Error: $exportpath does not exist"; exit 1
fi

if [ -z "$clientip" ];
then
[ -n "$DEFAULT_NET_IP" ] && [ -n "$DEFAULT_NETMASK" ] && \
clientip="$DEFAULT_NET_IP"/"$DEFAULT_NETMASK" || \
clientip="0.0.0.0/0.0.0.0"
echo No IP specified, exporting to "$clientip".
fi

echo "$exportpath $clientip($permissions,no_root_squash,sync,insecure)" >> /etc/exports && \
echo "Adding export: $exportpath $clientip($permissions,sync,no_root_squash,insecure)"
