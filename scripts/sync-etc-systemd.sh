#! /bin/sh

echo "Syncing /home/aetf/customizations/etc/systemd/system to /etc/systemd/system"
cp /home/aetf/customizations/etc/systemd/system/* /etc/systemd/system

#sleep a second before reload
sleep 1

echo "Daemon-reload"
systemctl daemon-reload

echo "Done"
