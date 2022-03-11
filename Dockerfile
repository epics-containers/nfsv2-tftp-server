FROM debian:jessie
EXPOSE 2049
# EXPOSE 111
# CMD ["/bin/bash"]
ADD serverfiles /nfsbuild
RUN mkdir /mnt/nfs_share; mkdir /mnt/nfs-public
RUN mkdir /var/state/; mkdir /var/state/nfs; touch /var/state/nfs/devtab
RUN cd /nfsbuild/debian; chmod +x init postinst preinst rules ugidd.init ugidd.preinst 
RUN apt update -y; apt install gcc make -y
RUN cd nfsbuild; cat debian/jamesbuild.cfg | ./BUILD
RUN cd /nfsbuild; make install;
RUN mkdir -p /mnt/nfs_share; chown -R nobody:nogroup /mnt/nfs_share; chmod 777 /mnt/nfs_share;
RUN mkdir /run/sendsigs.omit.d; touch /run/sendsigs.omit.d/rpcbind
ADD fstab /etc
ADD exports /etc
RUN touch /etc/services
#note: changing these ports to something else will cause the nfs-user-server start command to not work!
RUN echo sunrpc          111/tcp         rpcbind portmap >> /etc/services
RUN echo sunrpc          111/udp         rpcbind portmap >> /etc/services
RUN cp /nfsbuild/debian/init /etc/init.d/nfs-user-server
RUN apt install rpcbind -y;
# RUN bash /nfsbuild/debian/addaddresses.sh
# RUN echo "the \n character doesnt work"
# RUN service rpcbind start
# RUN /etc/init.d/nfs-user-server start
# ADD startservice.sh /
# RUN bash /startservice.sh
#cannot bind on tcp udp etc... maybe i should fix that 

# RUN echo remember to check the -r flag for rpc.mountd and rpc.nfsd
# RUN echo run rpc.nfsd --foreground and it will give you error message about not being able to bind UDP/TCP socket to given address etc.
# RUN echo remember you are running the --re-export flag in initr
#Using the --re-export gives a permission denied error.
#running rpc.nfsd --foreground -P DIFFERENT_PORT_THAN_2049 removes the address already in use error. MAYBE THIS IS WHERE WE NEED THE -R flag
#but no_subtree_check unknown keyword error remains.
#Doesnt seem like the no_subtree_check keyword is defined anywhere in this file system so makes sense.
#The address already in use error could be because I already have rpc.nfsd started in the background and the foreground process is separate.



#https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/storage_administration_guide/s2-nfs-methodology-portmap
#rpcinfo -p doesn't list service names.

# # # # RUN /etc/init.d/rpcbind stop
# ADD rpcbindwpath /etc/init.d/rpcbind; 

# RUN /etc/init.d/nfs-user-server start
# RUN service rpcbind start
# CMD ["/bin/bash"]
# showmount has RPC mapper failure RPC unable to send, but maybe we don't need it


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
