#/bin/bash
# 1) make local copy of /iocs/exports
# 2) Add listed exports in local copy, if directories exist
# 3) delete existing entries that use same IP or IOCName
# 4) periodically diff the local copy and exports, if changes, repeat


#https://stackoverflow.com/questions/13800225/while-loop-stops-reading-after-the-first-line-in-bash

function updateExports {
if [ ! -f /iocs/exports ]; then return; fi
rm -f /etc/requiredexports
cp /iocs/exports /etc/requiredexports
while IFS= read -r -u 9 line; do
if [ ! -z "$line" ]; then
    iocName="`echo $line | awk '{print $1}'`"
    iocIP="`echo $line | awk '{print $2}'`"
    autosave="`echo $line | awk '{print $3}'`"
    #something go weird with newlines here...
    #iocName=${words[0]}
    #iocIP=${words[1]}
    #autosave=${words[2]}
    echo "$iocName $iocIP $autosave"

    #check if /iocs/$iocName exists, and check if it's not already in /etc/exports
    #delete entries using same IP or IOC name (but not both) if they exist
    if [ -d /iocs/$iocName ] && ! grep "/iocs/$iocName $iocIP(" > /dev/null; then
        sed -i "/iocs\/.*$iocIP(/d" /etc/exports; sed -i "/^\/iocs\/$iocName /d" /etc/exports;
        echo "/iocs/$iocName $iocIP(ro,sync,no_root_squash,insecure)" >> /etc/exports
        changesMade=1
    fi

    #as above, but for autosave directories
    if [ "$autosave" = "autosave" ] && [ -d /autosave/$iocName ] && ! grep "/autosave/$iocName $iocIP(" > /dev/null; then
        sed -i "/autosave\/.*$iocIP(/d" /etc/exports; sed -i "/^\/autosave\/$iocName /d" /etc/exports;
        echo "/autosave/$iocName $iocIP(rw,sync,no_root_squash,insecure)" >> /etc/exports
        changesMade=1
    fi

fi
done 9< /etc/requiredexports

if [ "$changesMade" = 1 ]; then bash /etc/init.d/nfs-user-server restart; fi
changesMade=0
}


while true;
#if local copy different, then calls function.
do cmp --silent /etc/requiredexports /iocs/exports || updateExports
sleep 15; 
done