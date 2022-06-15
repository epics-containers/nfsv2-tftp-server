FROM debian:11.3
CMD ["/bin/bash"]
RUN apt update -y; \
    DEBIAN_FRONTEND=noninteractive apt install git gcc make rsyslog nfs-common dnsmasq net-tools -y

RUN git clone https://github.com/jgoerzen/nfs-user-server /serverfiles
COPY nfsbuild.patch buildoptions.cfg /
RUN patch -s -p0 < /nfsbuild.patch

RUN cd /serverfiles; cat /buildoptions.cfg | ./BUILD; \
    make install

RUN rm -rf /serverfiles /buildoptions.cfg /nfsbuild.patch

COPY scripts /scripts
RUN chmod +x -R /scripts
ENV PATH=/scripts/:$PATH

ENTRYPOINT ["/bin/bash", "-c", "bash startup.sh && sleep infinity"]
