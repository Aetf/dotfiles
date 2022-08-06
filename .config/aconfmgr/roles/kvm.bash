
AddPackage libvirt # API for controlling virtualization engines (openvz,kvm,qemu,virtualbox,xen,etc)
AddOptionalPackage libvirt \
    dnsmasq 'required for default NAT/DHCP for guests' `# Lightweight, easy to configure DNS forwarder and DHCP server`
AddPackage edk2-ovmf # Firmware for Virtual Machines (x86_64, i686)
AddPackage virt-manager # Desktop user interface for managing virtual machines
AddPackage virt-viewer # A lightweight interface for interacting with the graphical display of virtualized guest OS.
AddPackage guestfs-tools # Tools for accessing and modifying guest disk images

# Dependency chain:
# syslinux -> libguestfs -> guestfs-tools
# But we don't need syslinux
SetFileProperty /boot/syslinux deleted y
