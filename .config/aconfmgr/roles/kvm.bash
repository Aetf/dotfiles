AddPackage libvirt # API for controlling virtualization engines (openvz,kvm,qemu,virtualbox,xen,etc)
AddOptionalPackage libvirt \
    dnsmasq 'required for default NAT/DHCP for guests' `# Lightweight, easy to configure DNS forwarder and DHCP server` \
    iptables-nft 'required for default NAT networking' `# Linux kernel packet control tool (using nft interface)` \
    dmidecode 'DMI system info support' `# Desktop Management Interface table related utilities`

AddPackage qemu-base

SystemdEnable libvirt /usr/lib/systemd/system/libvirtd.service
SystemdEnable libvirt /usr/lib/systemd/system/virtlogd.socket
SystemdEnable libvirt /usr/lib/systemd/system/virtlockd.socket
SystemdEnable libvirt /usr/lib/systemd/system/libvirtd.socket
SystemdEnable libvirt /usr/lib/systemd/system/libvirtd-ro.socket

AddPackage edk2-ovmf # Firmware for Virtual Machines (x86_64, i686)

AddPackage virt-manager # Desktop user interface for managing virtual machines
AddPackage virt-viewer # A lightweight interface for interacting with the graphical display of virtualized guest OS.

AddPackage guestfs-tools # Tools for accessing and modifying guest disk images
# Dependency chain:
# syslinux -> libguestfs -> guestfs-tools
# But we don't need syslinux
## Tell pacman to not extract it
CopyFile /etc/pacman.d/confs/no-syslinux.conf
## Tell aconfmgr the file isn't there
SetFileProperty /boot/syslinux deleted y

