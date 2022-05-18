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
RUN chmod +x /restarts /addexport /start /init_with_ports /udppacketcounter /checkforexport
# RUN touch /etc/services
# RUN echo sunrpc          111/tcp         rpcbind portmap>> /etc/services
# RUN echo sunrpc          111/udp         rpcbind portmap>> /etc/services
RUN mv /init_with_ports /etc/init.d/nfs-user-server
#remember to use the -e flag for showmount to see exports

RUN mkdir /autosave; chown -R 777 /autosave
RUN mkdir /autosave/savefilepath; mkdir /autosave/reqfilepath
RUN touch /autosave/savefilepath/test_0.sav
RUN echo "k8s-epics-iocs:circle:angle" >> /autosave/reqfilepath/test_0.req
#remember to #include <time.h> in fh.c rpcmisc.c and logging.c

#####################
#everything below here is for TFTP
#####################

# ENTRYPOINT ["/bin/sh","-c", "sh /start && while true;do sleep infinity; done"]
ENTRYPOINT ["/bin/sh","-c", "sh /start & sh /checkforexport"]

# WORKDIR /tftp-http-proxy
# RUN apt update; apt install git python3 golang -y
# RUN go get -u github.com/pin/tftp
# RUN git clone https://github.com/bwalex/tftp-http-proxy . 
# ADD singleportpatch . 
# RUN patch -u main.go singleportpatch
# RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -o tftp
# ENTRYPOINT ["/bin/sh", "-c", "python3 -m http.server -b 127.0.0.1 80 --directory / &\
# /tftp-http-proxy/tftp -http-append-path & sh /start && sh /checkforexport"]
