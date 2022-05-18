FROM alpine:latest
RUN apk update; apk add git
ADD puller /
RUN chmod u+x /puller
ADD newpuller /
RUN chmod u+x /newpuller
ADD dbwriter /
RUN chmod u+x /dbwriter
#should add a line here to tftp onto cluster IP of the nfs server 
ENTRYPOINT ["/bin/sh", "-c", "sh /puller && sh /dbwriter && while true; do sleep infinity; done"]
#these should probably be done in a script so that Helm can set them without rebuilding
#may be better to cd directly into /iocs and pull so that if no updates nothing happens.