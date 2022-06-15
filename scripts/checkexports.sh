#!/bin/bash
while true;
#if changes made, updates exports list
do cmp --silent /etc/requiredexports /iocs/exports || /scripts/updateiocexports.sh
sleep 15;
done