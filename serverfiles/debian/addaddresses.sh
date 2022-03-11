echo "/mnt/nfs_share $(hostname -i)(rw,sync)" >> /etc/exports
echo "$(hostname -i):/mnt/nfs_share /mnt/nfs-public nfs rw 0 0" >> /etc/fstab