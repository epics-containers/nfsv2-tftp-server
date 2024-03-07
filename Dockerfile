FROM debian:12.5
CMD ["/bin/bash"]
RUN apt update -y; \
    DEBIAN_FRONTEND=noninteractive apt install git gcc make rsyslog nfs-common dnsmasq net-tools -y

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

ENTRYPOINT ["/bin/bash", "-c", "bash startup.sh && sleep infinity"]