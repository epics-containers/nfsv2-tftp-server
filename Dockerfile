FROM debian:11.3

CMD ["/bin/bash"]
RUN apt-get update -y; \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    dnsmasq \
    git \
    gcc \
    libntirpc-dev \
    make \
    nfs-common \
    net-tools \
    procps \
    rsync \
    rsyslog \
    vim

# nfs-user-server with v2 support is an abandoned project
# To protect against it disappearing we use a fork in dls-controls
RUN git clone https://github.com/dls-controls/nfs-user-server /serverfiles
COPY config /config
RUN patch -s -p0 < /config/nfsbuild.patch

RUN cd /serverfiles; cat /config/buildoptions.cfg | ./BUILD; \
    make install

COPY scripts /scripts
RUN chmod +x -R /scripts
ENV PATH=/scripts/:$PATH

# setup necessary folders
# sendsigs.omit.d Empirically required to start rpcbind
RUN mkdir -p /run/sendsigs.omit.d /iocs /autosave

# start an rsync deamon for debugging
COPY rsyncd.conf /etc/rsyncd.conf
RUN rsync --daemon

ENTRYPOINT ["/bin/bash", "-c", "bash startup.sh && sleep infinity"]
