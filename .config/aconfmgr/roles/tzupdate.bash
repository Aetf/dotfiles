
AddPackage tzupdate # Set the system timezone based on IP geolocation
CopyFile /etc/systemd/system/tzupdate.service
SystemdEnable --from-file /etc/systemd/system/tzupdate.service
