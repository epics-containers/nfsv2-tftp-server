#!/bin/bash
dontRestart=false
while getopts 'd' OPTION; do
    case "$OPTION" in
      d)
      dontRestart=true
      ;;
      *)
      ;;
    esac
done

changesMade=0

if [ ! -f /iocs/exports ]; then echo "/iocs/exports does not exist"; exit; fi
if [ ! -f /etc/exports ]; then touch /etc/exports; fi
rm -f /etc/requiredexports
cp /iocs/exports /etc/requiredexports
#Reads /iocs/exports line by line. Reads into "9" to avoid interruption when
#writing to stdin stdout stderr (0, 1, 2)
while IFS= read -r -u 9 line; do
if [ -n "$line" ]; then
    words=( "$line" )
    iocName="${words[0]}"
    iocIP="${words[1]}"
    autosave="${words[2]}"

    #check if /iocs/$iocName exists, and check if it's not already in /etc/exports
    #delete entries using same IP or IOC name if they exist
    if [ -d /iocs/"$iocName" ] && ! grep "/iocs/$iocName $iocIP(" > /dev/null; then
        sed -i "/iocs\/.*$iocIP(/d" /etc/exports; sed -i "/^\/iocs\/$iocName /d" /etc/exports;
        echo "/iocs/$iocName $iocIP(ro,sync,no_root_squash,insecure)" >> /etc/exports
        echo "Adding export: /iocs/$iocName $iocIP(ro,sync,no_root_squash,insecure)"
        changesMade=1
    fi

    #as above, but for autosave directories
    if [ "$autosave" = "autosave" ] && [ -d /autosave/"$iocName" ] && ! grep "/autosave/$iocName $iocIP(" > /dev/null; then
        sed -i "/autosave\/.*$iocIP(/d" /etc/exports; sed -i "/^\/autosave\/$iocName /d" /etc/exports;
        echo "/autosave/$iocName $iocIP(rw,sync,no_root_squash,insecure)" >> /etc/exports
        echo "Adding export: /autosave/$iocName $iocIP(rw,sync,no_root_squash,insecure)"
        changesMade=1
    fi

fi
done 9< /etc/requiredexports

if [ "$changesMade" = 1 ] && [ "$dontRestart" = "false" ]; then service nfs-user-server reload; fi