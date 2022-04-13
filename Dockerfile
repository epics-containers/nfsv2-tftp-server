# FROM debian:jessie
# debian jessie's package manager uses an old version of go that doesn't use the go mod command..
FROM debian:buster
#i think debian:11.3 has a sufficiently up to date version of golang...
# EXPOSE 2049
CMD ["/bin/bash"]
ADD serverfiles /nfsbuild
ADD buildoptions.cfg /nfsbuild
#Had to edit the line sh /configure in BUILD to sh /nfsbuild/configure...
RUN mkdir /var/state/; mkdir /var/state/nfs; touch /var/state/nfs/devtab
RUN apt update -y; apt install gcc make wget rsyslog nfs-common net-tools -y
RUN cd nfsbuild; cat buildoptions.cfg | ./BUILD
RUN cd /nfsbuild; make install;
RUN mkdir -p /exports/nfs_server; chown -R nobody:nogroup /exports/nfs_server; chmod 777 /exports/nfs_server;
RUN mkdir -p /mnt/nfs_client; chown -R nobody:nogroup /mnt/nfs_client; chmod 777 /mnt/nfs_client;
ADD exportedfiles /exports/nfs_server
RUN mkdir /run/sendsigs.omit.d; touch /run/sendsigs.omit.d/rpcbind
# RUN touch /etc/exports
ADD scripts /
RUN chmod +x /restarts /addexport /start /init_with_ports
# RUN touch /etc/services
# RUN echo sunrpc          111/tcp         rpcbind portmap>> /etc/services
# RUN echo sunrpc          111/udp         rpcbind portmap>> /etc/services
RUN mv /init_with_ports /etc/init.d/nfs-user-server
#remember to use the -e flag for showmount to see exports

#include <time.h> in fh.c rpcmisc.c and logging.c

#####################
#everything below here is for TFTP
#####################
#https://go.dev/doc/install/source
#debia/ubuntu go seems messed up so have to install from outside of package manager

RUN apt install wget -y 
RUN wget https://go.dev/dl/go1.18.linux-amd64.tar.gz
RUN tar -zxvf go1.18.linux-amd64.tar.gz -C /usr/local/
# RUN echo "export PATH=/usr/local/go/bin:${PATH}" | tee /etc/profile.d/go.sh
ENV PATH=/usr/local/go/bin:${PATH}
# RUN . /etc/profile.d/go.sh
# RUN ["/bin/bash", "-c", "source /etc/profile.d/go.sh"]

# # . is sh version of source

# RUN apt install golang -y


RUN mkdir /tftpboot
ADD exportedfiles /tftpboot
WORKDIR /build
COPY tftpserver .
#debian:jessie doesnt seem to recognise go mod?? command

RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -o tftp
RUN mv /build/tftp /tftp
ENTRYPOINT ["/tftp"]