MatchHost || return 0

AddRole base
AddRole packaging

# Booting
AddPackage linux-zen # The Linux ZEN kernel and modules
AddPackage linux-zen-headers # Headers and scripts for building modules for the Linux ZEN kernel
AddPackage intel-ucode # Microcode update files for Intel CPUs
AddPackage edk2-shell # EDK2 UEFI Shell

## Bootloader and uki infra
AddRole refind
AddRole initramfs-dracut

CopyFile /etc/pixmaps/dell.bmp
CreateLink /etc/pixmaps/oemlogo.bmp dell.bmp

## configure refind
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

## configure dracut for initramfs
CopyFile /etc/dracut.conf.d/early-kms.conf
CopyFile /etc/dracut.conf.d/blacklist-nouveau.conf
CopyFile /etc/dracut.conf.d/unused-modules.conf
### Make sure usb keyboard is usable early on
CopyFile /etc/dracut.conf.d/force-usb-keyboard.conf
### make sure resume from hibernation works
CopyFile /etc/dracut.conf.d/resume-from-hibernate.conf

## kernel command lines
CopyFile /etc/kernel/cmdline.d/block.conf
CopyFile /etc/kernel/cmdline.d/disable-audit.conf
CopyFile /etc/kernel/cmdline.d/s3-sleep.conf

CopyFile /etc/kernel/cmdline.d/normal/plymouth.conf

CopyFile /etc/kernel/cmdline.d/fallback/break.conf
CopyFile /etc/kernel/cmdline.d/fallback/verbose.conf

## configure plymouth
AddRole plymouth-oemlogo
CopyFile /etc/dracut.conf.d/install.d/normal/plymouth-oemlogo-font.conf

# Filesystem
AddPackage lvm2 # Logical Volume Manager 2 utilities
AddPackage btrfs-progs # Btrfs filesystem utilities
AddPackage xfsprogs # XFS filesystem utilities
CopyFile /etc/fstab

IsBootstrap && return 0

AddRole network-nm
AddRole zerotier
AddRole rich-cli
AddRole ssh

AddRole docker

AddRole kde
SystemdEnable sddm /usr/lib/systemd/system/sddm.service
AddRole cjk

AddRole games

AddRole latex
# AddRole android-dev
AddRole rust-dev
AddRole cpp-dev
AddRole python-dev
AddRole multimedia
AddRole tzupdate

# Login: fingerprint
AddPackage fprintd # D-Bus service to access fingerprint readers
AddPackage libfprint-2-tod1-xps9300-bin # Proprietary driver for the fingerprint reader on the Dell XPS 13 9300 - direct from Dell's Ubuntu repo
# AddPackage howdy # Windows Hello for Linux
CopyFile /etc/pam.d/system-auth

## Use kernel_keyring to try login using disk encryption password
awk -i inplace -f - "$(GetPackageOriginalFile pambase /etc/pam.d/system-login)" <<'EOF'
/^auth\s+include\s+system-auth/ {
  print "-auth      optional   pam_kernel_keyring.so"
}
{ print $0 }
EOF

# Hardware quirks
AddRole fwupd

# Sound
AddPackage linux-firmware # Firmware files for Linux
AddPackage sof-firmware # Sound Open Firmware

# Bluetooth
SystemdEnable bluez /usr/lib/systemd/system/bluetooth.service

# Video
AddPackage intel-media-driver # Intel Media Driver for VAAPI — Broadwell+ iGPUs
AddPackage mesa-utils # Essential Mesa utilities
AddPackage libva-utils # Intel VA-API Media Applications and Scripts for libva
AddPackage vdpauinfo # Command line utility for querying the capabilities of a VDPAU device
AddOptionalPackage mesa

AddPackage nvidia-dkms # NVIDIA drivers - module sources
AddPackage nvidia-prime # NVIDIA Prime Render Offload configuration and utilities
AddPackage nvidia-utils
CopyFile /etc/modprobe.d/nvidia-power.conf
SystemdEnable nvidia-utils /usr/lib/systemd/system/nvidia-resume.service
SystemdEnable nvidia-utils /usr/lib/systemd/system/nvidia-suspend.service
SystemdEnable nvidia-utils /usr/lib/systemd/system/nvidia-hibernate.service
SystemdEnable nvidia-utils /usr/lib/systemd/system/nvidia-suspend-then-hibernate.service
CopyFile /etc/modprobe.d/nvidia-modeset.conf
# CopyFile /etc/udev/rules.d/80-nvidia-pm.rules
# CopyFile /etc/pacman.d/confs/no-nvidia-vulkan.conf

# TODO: if docker
#AddPackage nvidia-container-runtime # NVIDIA opencontainer runtime fork to expose GPU devices to containers.

# Wifi
SystemdMask systemd-rfkill.service system
SystemdMask systemd-rfkill.socket system

# Touchpad
AddPackage libinput # Input device management and event handling library

# Camera
CopyFile /etc/udev/rules.d/83-webcam.rules

# Power
AddPackage tlp # Linux Advanced Power Management
AddPackage tlp-rdw # Linux Advanced Power Management - Radio Device Wizard
CopyFile /etc/tlp.d/cpu.conf
CopyFile /etc/tlp.d/pci-pm.conf
CopyFile /etc/tlp.d/rdw.conf
SystemdEnable tlp /usr/lib/systemd/system/tlp.service

CopyFile /etc/fan2go/fan2go.db 600
CopyFile /etc/fan2go/fan2go.yaml
CopyFile /etc/fancontrol

# Auto load sensor modules on boot
SystemdEnable lm_sensors /usr/lib/systemd/system/lm_sensors.service
CopyFile /etc/conf.d/lm_sensors

# Printers
AddPackage hplip # Drivers for HP DeskJet, OfficeJet, Photosmart, Business Inkjet and some LaserJet

# Keyboard
AddPackage zsa-udev # Udev rules for ZSA Keyboards (for boot flash mode)

# Donot autosuspend usb hub on the dock for faster switch
cat >$(CreateFile /etc/udev/rules.d/85-usb-no-suspend.rules) <<'EOF'
# Donot autosuspend usb hub on the dock for faster switch
ACTION=="add", SUBSYSTEM=="usb", ATTR{busnum}=="1", ATTR{idVendor}=="1d6b", ATTR{idProduct}=="0002", TEST=="power/control", ATTR{power/control}="on"
EOF

# Firewall
CopyFile /etc/firewalld/policies/nat.xml
CopyFile /etc/firewalld/zones/home.xml
CopyFile /etc/firewalld/zones/libvirt.xml
CopyFile /etc/firewalld/zones/trusted.xml
CopyFile /etc/firewalld/zones/veth.xml

# Additional apps
AddPackage pacvis-git # Visualize pacman local database using Vis.js, inspired by pacgraph
AddPackage ventoy-bin # A new multiboot USB solution
AddPackage github-cli # The GitHub CLI
AddPackage dnscontrol-bin # Synchronize your DNS to multiple providers from a simple DSL (binary release)
AddPackage pulumi # Modern Infrastructure as Code
AddPackage kubectl # A command line tool for communicating with a Kubernetes API server
AddPackage kubeseal # A Kubernetes controller and tool for one-way encrypted Secrets
AddPackage pamtester # Tiny program to test the pluggable authentication modules (PAM) facility
AddPackage syncthing
AddPackage packwiz-git # A command line tool for creating minecraft modpacks.
