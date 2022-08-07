# systemd-networkd is responsible for bringing up and configuring interfaces
SystemdEnable /usr/lib/systemd/system/systemd-networkd.service
## systemd-networkd will also enables systemd-networkd-wait-online.service.
## By default it will wait for all interfaces, but on our system, we consider
## the system online if any interface is configured.
CopyFile /etc/systemd/system/systemd-networkd-wait-online.service.d/wait-for-only-one-interface.conf

# and systemd-resolvd to provide DNS resolving and alike
SystemdEnable /usr/lib/systemd/system/systemd-resolvd.service
## the recommanded way to use systemd-resolvd is to use stub-resolv.conf
CreateLink /etc/resolv.conf /run/systemd/resolve/stub-resolv.conf

