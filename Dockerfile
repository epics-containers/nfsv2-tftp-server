FROM debian:11.3
CMD ["/bin/bash"]

COPY serverfiles /nfsbuild
COPY buildoptions.cfg /nfsbuild
RUN mkdir -p /var/state/nfs; touch /var/state/nfs/devtab
RUN apt update -y; \
    DEBIAN_FRONTEND=noninteractive apt install gcc make rsyslog nfs-common dnsmasq net-tools -y
RUN cd /nfsbuild; cat buildoptions.cfg | ./BUILD
RUN cd /nfsbuild; make install;
RUN mkdir -p /exports/nfs_server; chown -R nobody:nogroup /exports/nfs_server; chmod -R 777 /exports/nfs_server;
COPY exportedfiles /exports/nfs_server

COPY scripts /scripts
RUN chmod +x -R /scripts

ENTRYPOINT ["/bin/bash","-c", "bash /scripts/startup.sh && sleep infinity"]
