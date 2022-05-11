# FROM debian:jessie
# debian jessie's package manager uses an old version of go that doesn't use the go mod command..
FROM debian:11.3
# FROM ubuntu:20.04
#i think debian:11.3 has a sufficiently up to date version of golang...
# EXPOSE 2049
CMD ["/bin/bash"]
ADD serverfiles /nfsbuild
ADD buildoptions.cfg /nfsbuild
#Had to edit the line sh /configure in BUILD to sh /nfsbuild/configure...
RUN mkdir /var/state/; mkdir /var/state/nfs; touch /var/state/nfs/devtab
RUN apt update -y; DEBIAN_FRONTEND=noninteractive apt install golang gcc make wget rsyslog nfs-common dnsmasq net-tools -y
RUN cd nfsbuild; cat buildoptions.cfg | ./BUILD
RUN cd /nfsbuild; make install;
RUN mkdir -p /exports/nfs_server; chown -R nobody:nogroup /exports/nfs_server; chmod -R 777 /exports/nfs_server;
RUN mkdir -p /exports/server2; chown -R nobody:nogroup /exports/server2; chmod -R 777 /exports/server2;
# RUN mkdir -p /mnt/nfs_client; chown -R nobody:nogroup /mnt/nfs_client; chmod 777 /mnt/nfs_client;
ADD exportedfiles /exports/nfs_server
RUN mkdir /run/sendsigs.omit.d; touch /run/sendsigs.omit.d/rpcbind
# RUN touch /etc/exports
ADD scripts /
RUN chmod +x /restarts /addexport /start /init_with_ports /udppacketcounter
# RUN touch /etc/services
# RUN echo sunrpc          111/tcp         rpcbind portmap>> /etc/services
# RUN echo sunrpc          111/udp         rpcbind portmap>> /etc/services
RUN mv /init_with_ports /etc/init.d/nfs-user-server
#remember to use the -e flag for showmount to see exports

#include <time.h> in fh.c rpcmisc.c and logging.c

#####################
#everything below here is for TFTP
#####################

# most of the configuration for dnsmasq is done in /start
# ENTRYPOINT [ "/bin/bash", "bash /start" ]
ENTRYPOINT ["/bin/sh","-c", "sh /start && while true; do continue; sleep 10;done"]