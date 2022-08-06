MatchHost || return 0

AddRole booting-refind
AddRole base
AddRole network-nm
AddRole rich-cli
AddRole packaging
AddRole ssh
AddRole font

AddRole docker

AddRole kde
AddRole cjk

AddRole kvm
AddRole games
AddRole samba

AddRole latex
AddRole android-dev
AddRole rust-dev
AddRole cpp-dev
AddRole python-dev
AddRole multimedia
AddRole tzupdate

# Booting
AddPackage linux-zen # The Linux ZEN kernel and modules
AddPackage linux-zen-headers # Headers and scripts for building modules for the Linux ZEN kernel

CopyFile /etc/pixmaps/dell.bmp
CreateLink /etc/pixmaps/oemlogo.bmp dell.bmp

AddPackage intel-ucode # Microcode update files for Intel CPUs
AddPackage edk2-shell # EDK2 UEFI Shell

# configure refind
AddPackage refind-theme-regular-git # A simplistic clean and minimal theme for rEFInd
CopyFile /etc/refind.d/overlay/00-theme.conf
CopyFile /etc/refind.d/overlay/90-user.conf
CopyFile /etc/refind.d/overlay/99-local.conf
CopyFile /etc/refind.d/overlay/fonts/mkfonts.py 755
CopyFile /etc/refind.d/overlay/fonts/source-code-pro-16.png
CopyFile /etc/refind.d/overlay/fonts/source-code-pro-20.png
CopyFile /etc/refind.d/overlay/fonts/source-code-pro-32.png
CreateLink /etc/refind.d/overlay/oemlogo.bmp /etc/pixmaps/oemlogo.bmp
CreateLink /etc/refind.d/overlay/refind-theme-regular /usr/share/refind/themes/refind-theme-regular/

# configure dracut for initramfs
CopyFile /etc/dracut.conf.d/blacklist-nouveau.conf
CopyFile /etc/dracut.conf.d/uefi.conf
CopyFile /etc/dracut.conf.d/unused-modules.conf


CopyFile /etc/dracut.conf.d/cmdline.d/block.conf
CopyFile /etc/dracut.conf.d/cmdline.d/disable-audit.conf
CopyFile /etc/dracut.conf.d/cmdline.d/s3-sleep.conf

CopyFile /etc/dracut.conf.d/cmdline.d/normal/plymouth.conf

CopyFile /etc/dracut.conf.d/cmdline.d/fallback/break.conf
CopyFile /etc/dracut.conf.d/cmdline.d/fallback/verbose.conf

# configure plymouth
AddRole plymouth-oemlogo
CopyFile /etc/dracut.conf.d/install.d/normal/plymouth-oemlogo-font.conf

# Filesystem
AddPackage lvm2 # Logical Volume Manager 2 utilities
AddPackage btrfs-progs # Btrfs filesystem utilities
AddPackage zfs-dkms # Kernel modules for the Zettabyte File System.
AddPackage xfsprogs # XFS filesystem utilities
CopyFile /etc/fstab
CopyFile /etc/systemd/system/mnt-Aetf\\x2dLaptop.automount
CopyFile /etc/systemd/system/mnt-Aetf\\x2dLaptop.mount

# Login: face cam, fingerprint
AddPackage fprintd # D-Bus service to access fingerprint readers
AddPackage libfprint-2-tod1-xps9300-bin # Proprietary driver for the fingerprint reader on the Dell XPS 13 9300 - direct from Dell's Ubuntu repo
AddPackage howdy # Windows Hello for Linux
CopyFile /etc/pam.d/system-auth
CopyFile /etc/pam.d/system-auth-chain
CopyFile /etc/pam.d/system-login

# Sound
AddPackage linux-firmware # Firmware files for Linux
AddPackage sof-firmware # Sound Open Firmware

# Bluetooth
# TODO: use systemd enable
CreateLink /etc/systemd/system/dbus-org.bluez.service /usr/lib/systemd/system/bluetooth.service

# Video
AddPackage intel-media-driver # Intel Media Driver for VAAPI — Broadwell+ iGPUs
AddPackage mesa-utils # Essential Mesa utilities
AddPackage libva-utils # Intel VA-API Media Applications and Scripts for libva
AddPackage vdpauinfo # Command line utility for querying the capabilities of a VDPAU device
AddOptionalPackage mesa \
    libva-mesa-driver 'for accelerated video playback' `# VA-API implementation for gallium`

AddPackage nvidia-dkms # NVIDIA drivers - module sources
AddPackage nvidia-prime # NVIDIA Prime Render Offload configuration and utilities
CopyFile /etc/modprobe.d/nvidia-power.conf
CopyFile /etc/udev/rules.d/80-nvidia-pm.rules

# TODO: if docker
AddPackage nvidia-container-runtime # NVIDIA opencontainer runtime fork to expose GPU devices to containers.

# Wifi
CreateLink /etc/systemd/system/systemd-rfkill.service /dev/null
CreateLink /etc/systemd/system/systemd-rfkill.socket /dev/null

# Touchpad
AddPackage libinput-three-finger-drag # Input device management and event handling library

# Camera
CopyFile /etc/udev/rules.d/83-webcam.rules

# Power
AddPackage tlp # Linux Advanced Power Management
AddPackage tlp-rdw # Linux Advanced Power Management - Radio Device Wizard
CopyFile /etc/tlp.d/cpu.conf
CopyFile /etc/tlp.d/pci-pm.conf
CopyFile /etc/tlp.d/rdw.conf

CopyFile /etc/fan2go/fan2go.db 600
CopyFile /etc/fan2go/fan2go.yaml
CopyFile /etc/fancontrol

CopyFile /etc/conf.d/lm_sensors

# Printers
AddPackage hplip # Drivers for HP DeskJet, OfficeJet, Photosmart, Business Inkjet and some LaserJet

# Keyboard
AddPackage zsa-udev # Udev rules for ZSA Keyboards (for boot flash mode)

# Firewall
CopyFile /etc/firewalld/policies/nat.xml
CopyFile /etc/firewalld/zones/home.xml
CopyFile /etc/firewalld/zones/libvirt.xml
CopyFile /etc/firewalld/zones/trusted.xml
CopyFile /etc/firewalld/zones/veth.xml

