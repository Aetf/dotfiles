#! /bin/sh

# checking root access
if [[ ! $UID = 0 ]]; then
        sudo $0
        exit 0
fi

for x in /sys/block/sd*
do
    dev=$(basename $x)
    host=$(ls -l $x | egrep -o "host[0-9]+")
    target=$(ls -l $x | egrep -o "target[0-9:]*")
    a=$(cat /sys/class/scsi_host/$host/unique_id)
    a2=$(echo $target | egrep -o "[0-9]:[0-9]$" | sed 's/://')
    serial=$(hdparm -I /dev/$dev | grep "Serial Number" | sed 's/^[ \t]*//')
    echo -e "$dev \t ata$a.$a2 \t $serial"
done
