
AddPackage networkmanager # Network connection manager and user applications
AddPackage networkmanager-openconnect # NetworkManager VPN plugin for OpenConnect
AddOptionalPackage networkmanager-openconnect \
    libnma-gtk4 'GUI support (GTK 4)' `# NetworkManager GUI client library (GTK4)`
AddPackage networkmanager-vpnc # NetworkManager VPN plugin for VPNC
AddOptionalPackage networkmanager-vpnc \
    libnma-gtk4 'GUI support (GTK 4)' `# NetworkManager GUI client library (GTK4)`


CreateLink /etc/resolv.conf /run/NetworkManager/resolv.conf
CopyFile /etc/NetworkManager/conf.d/ignore-docker.conf

AddPackage firewalld # Firewall daemon with D-Bus interface
CopyFile /etc/firewalld/firewalld.conf 600

# TODO: use systemd enable
CreateLink /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service /usr/lib/systemd/system/firewalld.service

CopyFile /etc/sysctl.d/30-ipforward.conf
