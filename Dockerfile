FROM debian:jessie
EXPOSE 2049
EXPOSE 111
# FROM ubuntu
CMD ["/bin/bash"]
ADD serverfiles /nfsbuild
RUN touch /var/state/nfs/devtab
RUN cd /nfsbuild/debian; chmod +x init postinst preinst rules ugidd.init ugidd.preinst 
RUN apt update -y; apt install gcc make -y
RUN cd nfsbuild; cat debian/jamesbuild.cfg | ./BUILD
RUN cd /nfsbuild; make install;
RUN mkdir -p /mnt/nfs_share; chown -R nobody:nogroup /mnt/nfs_share; chmod 777 /mnt/nfs_share;
ADD exports /etc
RUN touch /etc/services
RUN echo sunrpc          111/tcp         rpcbind portmap >> /etc/services
RUN echo sunrpc          111/udp         rpcbind portmap >> /etc/services
RUN apt install rpcbind -y; /etc/init.d/rpcbind stop
ADD rpcbindwpath /etc/init.d/rpcbind; 
RUN /etc/init.d/rpcbind stop; /etc/init.d/rpcbind start
RUN cp /nfsbuild/debian/init /etc/init.d/nfs-user-server
RUN rpcbind start
RUN /etc/init.d/nfs-user-server start
#this now gives a "Starting NFS servers: nfsd mountd" confirmation message, but i'm not sure if the actual commands are being
#executed e.g. start-stop-daemon --start --oknodo --quiet --exec /usr/sbin/rpc.nfsd
#Not sure if rpcbind service is working properly.
#/etc/init.d/rpcbind status usually doesnt seem promising
#check where device mapping is stored, this may be important!! (dnm)
#doesn't seem like the file even gets made...


# RUN mkdir /var/nfs; mkdir /var/nfs/public; chmod 777 /var/nfs/public
# RUN mkdir /mnt/nfs-public
# RUN echo hey there hey there >> /mnt/nfs-public/hey.txt
# ADD exports /etc
# ADD fstab /etc
# RUN apt install rpcbind -y; mv /rpcbindwpath /etc/init.d/rpcbind
#https://www.youtube.com/watch?v=hC7QNtID4-4
#https://askubuntu.com/questions/771473/mount-cant-find-device-in-etc-fstab
#https://packages.qa.debian.org/n/nfs-user-server.html
#https://www.ducea.com/2006/09/11/error-servname-not-supported-for-ai_socktype/ 
#https://www.lifewire.com/what-is-etc-services-2196940
