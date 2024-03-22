#!/bin/bash

# Startup script to bring up NFSv2 and TFTP services

echo configuring NFSv2 and TFTP
echo ...

# Remove the imklog module from rsyslog, which provides kernel logging
sed -i '/imklog/s/^/#/' /etc/rsyslog.conf

# Hack alert
#
# rpcbind service file looks for the permissions of /run/rpcbind
# but it makes an assumption that breaks when selinux is active
# as it is on RHEL8 nodes. Below fixes a regex to allow this case
#
sed -i 's/drwxr-xr-x/drwxr-xr-x[\\.]?/g' /etc/init.d/rpcbind

service rsyslog start

# Some container images do not create /etc/services file which maps services to ports
[ ! -f /etc/services ] && \
    echo "sunrpc          111/tcp         rpcbind portmap" >> /etc/services && \
    echo "sunrpc          111/udp         rpcbind portmap" >> /etc/services

echo 'alias "nfs"="service nfs-user-server"' >> "$HOME"/.bashrc
cp /scripts/nfs-user-server-init /etc/init.d/nfs-user-server

# Configure exports file
if [ -n "$DEFAULT_NET_IP" ] && [ -n "$DEFAULT_NETMASK" ];
then
[ -d /iocs ] && echo "/iocs $DEFAULT_NET_IP/$DEFAULT_NETMASK(ro,sync,no_root_squash,insecure)" >> /etc/exports
[ -d /autosave ] && echo "/autosave $DEFAULT_NET_IP/$DEFAULT_NETMASK(rw,sync,no_root_squash,insecure)" >> /etc/exports
else
[ -d /iocs ] && echo "/iocs 0.0.0.0/0.0.0.0(ro,sync,no_root_squash,insecure)" >> /etc/exports
[ -d /autosave ] && echo "/autosave 0.0.0.0/0.0.0.0(rw,sync,no_root_squash,insecure)" >> /etc/exports
fi

# Start services for NFS
service rpcbind start
service nfs-user-server start

# Start TFTP
dnsmasq -p 0 --enable-tftp --tftp-single-port --tftp-root /iocs --log-facility=/var/log/syslog

echo NFSv2 and TFTP server now live ...

rsync --daemon

echo rsync server now live ...
