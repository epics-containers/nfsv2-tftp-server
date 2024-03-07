This repository contains all the tools to set up a combined NFSv2 and TFTP server in Kubernetes. 
The Dockerfile is built on a Debian:11.3 image, the latest version at time of writing. It should
be fairly portable to other base images but would require rewriting of scripts/nfs-user-server-init if start-stop-daemon is not included. 

The version of TFTP used is the one included in the dnsmasq package. In order to simplify the Kubernetes configuration, it is advised to use a recent version of dnsmasq that includes the --tftp-single-port option, which forces all TFTP packets from the server to be sent from the same fixed port 69 instead of a random ephemeral port. 

For NFSv2, The LINUX User Space NFS Server is used, pulling from a non-maintainer build for Debian from 2017. nfsbuild.patch includes some fixes needed to make the BUILD script run, and also a patch to lower the default maximum packet transfer size from 8kB to 1kB - this may help to prevent timeouts for large files transfers over UDP when exposing the server via a Kubernetes LoadBalancer with spec.externalTrafficPolicy set to the default value (Cluster).

The resulting image requires use of 4 ports over UDP, these are
69: dnsmasq (TFTP)
111: rpcbind/portmapper service (NFS)
2049: rpc.nfsd (NFS)
20048: rpc.mountd (NFS)
The last two may be changed by editing scripts/nfs-user-server-init

The buildoptions.cfg file is piped into the NFS server's BUILD script to automate the configuration. 

Most of the scripts in the scripts directory are specific to the RTEMS EPICS IOCs delivery prototype project at Diamond. 
These scripts expect that the server pod has access to two Persistent Volume k8s objects mounted on /iocs and /autosave.

startup.sh: Starts server and logging processes. If EXPORT_PER_CLIENT=true is set in the YAML file, the scripts above get called to add the paths specified in /iocs/exports to /etc/exports, otherwise the entire /autosave and /iocs directories are exported to all clients on the default subnet specified in the environment by $DEFAULT_NET_IP and $DEFAULT_NETMASK. Note that wildcard and CIDR notation do not appear to work in The LINUX User Space NFS Server, so the subnet mask should be specified explicitly. 

