#!/bin/bash
mkdir -p /run/sendsigs.omit.d
# mkdir -p /var/state/nfs; touch /var/state/nfs/devtab

sed -i '/imklog/s/^/#/' /etc/rsyslog.conf
#removes the imklog module, which provides kernel logging
service rsyslog start

if [ "${EXPORT_PER_CLIENT}" != "true" ]; then
[ -d /iocs ] && echo "/iocs 0.0.0.0/0.0.0.0(ro,sync,no_root_squash,insecure)" >> /etc/exports
[ -d /autosave ] && echo "/autosave 0.0.0.0/0.0.0.0(rw,sync,no_root_squash,insecure)" >> /etc/exports
fi


chmod -R 777 /autosave 

[ ! -f /etc/services ] && \
    echo "sunrpc          111/tcp         rpcbind portmap" >> /etc/services && \
    echo "sunrpc          111/udp         rpcbind portmap" >> /etc/services
#Some container images do not create /etc/services file which maps services to ports

cp /scripts/nfs-user-server-init /etc/init.d/nfs-user-server

if [ "${EXPORT_PER_CLIENT}" = "true" ]; then
/scripts/updateexports.sh -d
fi

service rpcbind start
service nfs-user-server start

dnsmasq -p 0 --enable-tftp --tftp-single-port --tftp-root /iocs --log-facility=/var/log/syslog

if [ "${EXPORT_PER_CLIENT}" = "true" ]; then
/scripts/checkexports.sh
fi