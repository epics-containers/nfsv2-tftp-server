#!/bin/bash
mkdir -p /run/sendsigs.omit.d
# mkdir -p /var/state/nfs; touch /var/state/nfs/devtab

sed -i '/imklog/s/^/#/' /etc/rsyslog.conf
#removes the imklog module, which provides kernel logging
service rsyslog start

[ ! -f /etc/services ] && \
    echo "sunrpc          111/tcp         rpcbind portmap" >> /etc/services && \
    echo "sunrpc          111/udp         rpcbind portmap" >> /etc/services
#Some container images do not create /etc/services file which maps services to ports

cp /scripts/nfs-user-server-init /etc/init.d/nfs-user-server
touch /etc/exports

service rpcbind start
service nfs-user-server start
echo 'alias "nfs"="service nfs-user-server"' >> "$HOME"/.bashrc

mkdir -p /tftpboot
dnsmasq -p 0 --enable-tftp --tftp-single-port --tftp-root /tftpboot --log-facility=/var/log/syslog
