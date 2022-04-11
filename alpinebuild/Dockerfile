FROM alpine
RUN apk update; apk add rpcbind nfs-utils
RUN echo "rpcbind 111/tcp" >> /etc/services; echo "rpcbind 111/udp" >> /etc/services
RUN /sbin/rpcbind stop; /sbin/rpcbind start