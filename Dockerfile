FROM debian
# FROM ubuntu
CMD ["/bin/bash"]
ADD serverfiles /nfsbuild
RUN apt update -y; apt install gcc make -y
RUN cd nfsbuild; cat debian/jamesbuild.cfg | ./BUILD

#you have to be IN the directory and run ./BUILD