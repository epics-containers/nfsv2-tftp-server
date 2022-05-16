# echo "/exports/nfs_server $(hostname -i)(rw,sync,no_root_squash,insecure)" >> /etc/exports
# echo "/exports/nfs_server 127.0.0.1(rw,sync,no_root_squash,insecure)" >> /etc/exports
# echo "/exports/nfs_server 172.23.245.130/20(rw,sync,no_root_squash,insecure)" >> /etc/exports
# echo "/exports/nfs_server *(rw,sync,no_root_squash,insecure)" >> /etc/exports

# echo "/exports/nfs_server 10.46.128.0/12(rw,sync,no_root_squash,insecure)" >> /etc/exports
# echo "/exports/nfs_server 10.32.0.1/12(rw,sync,no_root_squash,insecure)" >> /etc/exports

# echo "/exports/nfs_server 10.0.0.0/255.0.0.0(rw,sync,no_root_squash,insecure)" >> /etc/exports
echo "/exports/nfs_server 0.0.0.0/0.0.0.0(rw,sync,no_root_squash,insecure)" >> /etc/exports
echo "/exports/server2 0.0.0.0/0.0.0.0(rw,sync,no_root_squash,insecure)" >> /etc/exports

# echo "/exports/nfs_server 172.23.169.20(rw,sync,no_root_squash,insecure)" >> /etc/exports
# echo "/exports/nfs_server 10.96.185.74(rw,sync,no_root_squash,insecure)">>etc/exports 

echo "$(hostname -i):/exports/nfs_server  /mnt/nfs_client nfs rw 0 0" >> /etc/fstab
echo "127.0.0.1:/exports/nfs_server  /mnt/nfs_client nfs rw 0 0" >> /etc/fstab\
