#!/bin/bash
while true;
#if changes made, updates exports list
do cmp --silent /etc/requiredexports /iocs/exports || updateiocexports.sh
sleep ${1:-15};
done