#!/bin/bash
cd /iocs || exit 1

for file in ./*/version.txt;
do

if [ -f "$file" ]
then 
basedirectory=$(echo "$file" | awk -F "/" '{print $2}')
printf "%s: %s \n" "$basedirectory" "$(cat "$file")"
fi


done