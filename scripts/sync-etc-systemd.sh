#! /bin/sh

echo "Syncing /home/aetf/customizations/etc/systemd/system to /etc/systemd/system"
cp /home/aetf/customizations/etc/systemd/system/*.{service,socket,device,mount,automount,swap,target,path,timer,snapshot,slice,scope} /etc/systemd/system

#sleep a second before reload
sleep 1

echo "Daemon-reload"
systemctl daemon-reload

echo "Done"
