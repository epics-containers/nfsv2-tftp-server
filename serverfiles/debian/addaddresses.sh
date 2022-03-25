echo "/exports/nfs_server $(hostname -i)(rw,sync,no_root_squash,insecure)" >> /etc/exports
echo "/exports/nfs_server 127.0.0.1(rw,sync,no_root_squash,insecure)" >> /etc/exports
echo "/exports/nfs_server 172.23.245.130/20(rw,sync,no_root_squash,insecure)" >> /etc/exports
echo "/exports/nfs_server *(rw,sync,no_root_squash,insecure)" >> /etc/exports
echo "$(hostname -i):/exports/nfs_server  /mnt/nfs_client nfs rw 0 0" >> /etc/fstab
echo "127.0.0.1:/exports/nfs_server  /mnt/nfs_client nfs rw 0 0" >> /etc/fstab