echo "/mnt/nfs_share $(hostname -i)(rw,sync,no_root_squash,insecure)" >> /etc/exports
echo "/mnt/nfs_share 127.0.0.1(rw,sync,no_root_squash,insecure)" >> /etc/exports
echo "$(hostname -i):/mnt/nfs_server /mnt/nfs_client nfs rw 0 0" >> /etc/fstab
echo "127.0.0.1:/mnt/nfs_server /mnt/nfs_client nfs rw 0 0" >> /etc/fstab