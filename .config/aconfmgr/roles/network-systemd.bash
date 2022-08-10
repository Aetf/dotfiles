# systemd-networkd is responsible for bringing up and configuring interfaces
SystemdEnable systemd /usr/lib/systemd/system/systemd-networkd.service
## systemd-networkd will also enables systemd-networkd-wait-online.service.
## By default it will wait for all interfaces, but on our system, we consider
## the system online if any interface is configured.
CopyFile /etc/systemd/system/systemd-networkd-wait-online.service.d/wait-for-only-one-interface.conf

# and systemd-resolved to provide DNS resolving and alike
SystemdEnable systemd /usr/lib/systemd/system/systemd-resolved.service
## the recommanded way to use systemd-resolved is to use stub-resolv.conf
CreateLink /etc/resolv.conf /run/systemd/resolve/stub-resolv.conf

