AddPackage iptables-nft # Linux kernel packet control tool (using nft interface)

AddPackage networkmanager # Network connection manager and user applications
AddPackage networkmanager-openconnect # NetworkManager VPN plugin for OpenConnect
AddOptionalPackage networkmanager-openconnect \
    libnma-gtk4 'GUI support (GTK 4)' `# NetworkManager GUI client library (GTK4)`
AddPackage networkmanager-vpnc # NetworkManager VPN plugin for VPNC
AddOptionalPackage networkmanager-vpnc \
    libnma-gtk4 'GUI support (GTK 4)' `# NetworkManager GUI client library (GTK4)`

SystemdEnable networkmanager /usr/lib/systemd/system/NetworkManager.service
SystemdEnable networkmanager /usr/lib/systemd/system/NetworkManager-wait-online.service

CopyFile /etc/NetworkManager/conf.d/ignore-docker.conf
CopyFile /etc/NetworkManager/conf.d/ignore-zerotier.conf

# and systemd-resolved to provide DNS resolving and alike
# networkmanager will automatically use systemd-resolved if the symlink is present
SystemdEnable systemd /usr/lib/systemd/system/systemd-resolved.service
## the recommanded way to use systemd-resolved is to use stub-resolv.conf
### In bootstrap, we are in chroot environment, /etc/resolv.conf is
### bind-mounted from the outside system, so it is not possible to modify.
if IsBootstrap; then
    IgnorePath /etc/resolv.conf
else
    CreateLink /etc/resolv.conf /run/systemd/resolve/stub-resolv.conf
fi


AddPackage firewalld # Firewall daemon with D-Bus interface
CopyFile /etc/firewalld/firewalld.conf 600
SystemdEnable firewalld /usr/lib/systemd/system/firewalld.service

CopyFile /etc/sysctl.d/30-ipforward.conf
