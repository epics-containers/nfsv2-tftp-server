FROM debian:jessie
# FROM ubuntu
EXPOSE 2049
# EXPOSE 111
# CMD ["/bin/bash"]
ADD serverfiles /nfsbuild
#Had to edit the line sh /configure in BUILD to sh /nfsbuild/configure...
RUN mkdir /var/state/; mkdir /var/state/nfs; touch /var/state/nfs/devtab
RUN cd /nfsbuild/debian; chmod +x init postinst preinst rules ugidd.init ugidd.preinst 
RUN apt update -y; apt install gcc make -y

#trying this to setup logging..
RUN apt install rsyslog -y 


RUN cd nfsbuild; cat debian/jamesbuild2.cfg | ./BUILD
RUN cd /nfsbuild; make install;
RUN mkdir -p /exports/nfs_server; chown -R nobody:nogroup /exports/nfs_server; chmod 777 /exports/nfs_server;
RUN mkdir -p /mnt/nfs_client; chown -R nobody:nogroup /mnt/nfs_client; chmod 777 /mnt/nfs_client;
ADD moby.txt /
ADD sizefiles /sizefiles
RUN mkdir /run/sendsigs.omit.d; touch /run/sendsigs.omit.d/rpcbind
ADD fstab /etc
ADD exports /etc
ADD start /
ADD addexport /
ADD exporttohosts / 
ADD restarts / 
ADD restart / 
ADD restart65s /
RUN chmod +x /start
RUN chmod +x /restart65s; chmod +x /restarts; chmod +x /restart
RUN chmod +x /addexport; chmod +x exporttohosts
RUN touch /etc/services
#note: changing these ports to something else will cause the nfs-user-server start command to not work!

#remove "nfs" alias from these lines if something breaks..
RUN echo sunrpc          111/tcp         rpcbind portmap nfs>> /etc/services
RUN echo sunrpc          111/udp         rpcbind portmap>> /etc/services
RUN echo nfsd          2049/tcp         rpc.nfsd nfs>> /etc/services
RUN echo nfsd          2049/tcp         rpc.nfsd nfs>> /etc/services
RUN echo mountd          20048/tcp         rpc.mountd nfs>> /etc/services
RUN echo mountd          20048/tcp         rpc.mountd nfs>> /etc/services
# RUN apt install rpcbind -y;
RUN cp /nfsbuild/debian/initr /etc/init.d/nfs-user-server
RUN apt install nfs-common net-tools -y
#remember i am now using jamesbuild2.cfg instead of jamesbuild.cfg...
#secure flag: server won't respond to TCP requests at ports > 1024


#remember to use the -e flag for showmount to see exports

#include <time.h> in fh.c rpcmisc.c and logging.c

#if you run the pod with --privileged flag you get additional errors trying to mount
#mount.nfs is in /sbin
#run mount $(hostname -i):/mnt/nfs_server -V; ls /mnt/nfs-public after starting services in privileged mode, gives some errors.

# Do i have to specify nfsversion in mount command?
# RUN echo "the \n character doesnt work"

# RUN echo remember to check the -r flag for rpc.mountd and rpc.nfsd
# RUN echo remember you are running the --re-export flag in initr
#set a port flag for the rpc.mountd service too
#Using the --re-export gives a permission denied error.
#no no_subtree_check keyword
#The address already in use error could be because I already have rpc.nfsd started in the background and the foreground process is separate.



#https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/storage_administration_guide/s2-nfs-methodology-portmap
#rpcinfo -p doesn't list service names.

# # # # RUN /etc/init.d/rpcbind stop
# ADD rpcbindwpath /etc/init.d/rpcbind; 

# RUN /etc/init.d/nfs-user-server start
# RUN service rpcbind start
# CMD ["/bin/bash"]
# showmount requires an address to work e.g. showmount localhost


#VERY IMPORTANT: SEE THIS TRICK https://wiki.openvz.org/NFS_server_inside_container#User-space_NFS_server
#see if you can use -S flag with -- in start-stop-daemon for this

#seems like you need to service rpcbind start in the terminal but doesnt work during building...

#try running mount 10.0.2.100:/mnt/nfs_share /mnt/nfs-public


#this now gives a "Starting NFS servers: nfsd mountd" confirmation message, but i'm not sure if the actual commands are being
#executed e.g. start-stop-daemon --start --oknodo --exec /usr/sbin/rpc.nfsd
#Not sure if rpcbind service is working properly.
#/etc/init.d/rpcbind status usually doesnt seem promising
#check where device mapping is stored, this may be important!! (dnm)
#doesn't seem like the file even gets made...
#Running /usr/sbin/rpc.nfsd etc gives "Cannot register service: RPC: Unable to receive; errno = Connection refused"
#rpcinfo -> can't contact rpcbind: RPC: Remote system error - No such file or directory.

# RUN apt install rpcbind -y; mv /rpcbindwpath /etc/init.d/rpcbind
#https://www.youtube.com/watch?v=hC7QNtID4-4
#https://askubuntu.com/questions/771473/mount-cant-find-device-in-etc-fstab
#https://packages.qa.debian.org/n/nfs-user-server.html
#https://www.ducea.com/2006/09/11/error-servname-not-supported-for-ai_socktype/ 
#https://www.lifewire.com/what-is-etc-services-2196940
