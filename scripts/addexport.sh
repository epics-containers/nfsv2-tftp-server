#!/bin/sh

#check if already in exports before adding
grep $1 /etc/exports || echo "$1 ${2:-0.0.0.0/0.0.0.0}(rw,sync,no_root_squash,insecure)" >> /etc/exports; \
echo "New export added: $1"; \
/scripts/restart.sh
