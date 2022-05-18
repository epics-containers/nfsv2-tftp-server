FROM debian:11.3
CMD ["/bin/bash"]

ADD serverfiles /nfsbuild
ADD buildoptions.cfg /nfsbuild
RUN mkdir /var/state/; mkdir /var/state/nfs; touch /var/state/nfs/devtab
RUN apt update -y; \
    DEBIAN_FRONTEND=noninteractive apt install gcc make rsyslog nfs-common dnsmasq net-tools -y
RUN cd /nfsbuild; cat buildoptions.cfg | ./BUILD
RUN cd /nfsbuild; make install;
RUN mkdir -p /exports/nfs_server; chown -R nobody:nogroup /exports/nfs_server; chmod -R 777 /exports/nfs_server;
ADD exportedfiles /exports/nfs_server

ADD scripts /scripts
RUN chmod +x -R /scripts

RUN mkdir /autosave; chown -R 777 /autosave && \
    mkdir /autosave/savefilepath; mkdir /autosave/reqfilepath && \
    touch /autosave/savefilepath/test_0.sav && \
    echo "k8s-epics-iocs:circle:angle" >> /autosave/reqfilepath/test_0.req

ENTRYPOINT ["/bin/sh","-c", "sh /scripts/start & sh /scripts/checkforexport"]
