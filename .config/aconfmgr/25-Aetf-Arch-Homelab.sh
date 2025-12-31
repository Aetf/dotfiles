MatchHost || return 0

# This host serves as the homelab server in house, joining the k8s cluster as a worker.
# As such, it has the minimal amount of packages.

# We first make sure bootstrapping is completed

# First ack the base installation.
AddRole base

# For filesystem layout, we rely on systemd-gpt-auto-generator, so make sure
# /etc/fstab is clean.
GetPackageOriginalFile filesystem /etc/fstab >/dev/null
# Rest of the configs asumes ESP mounted at /efi, from systemd doc:
#   Mount and automount units for the EFI System Partition (ESP) are generated
#   on EFI systems. The ESP is mounted to /boot/ (except if an Extended Boot
#   Loader partition exists, see below), unless a mount point directory /efi/
#   exists, in which case it is mounted there. Since this generator creates an
#   automount unit, the mount will only be activated on-demand, when accessed.
#   On systems where /boot/ (or /efi/ if it exists) is an explicitly configured
#   mount (for example, listed in fstab(5)) or where the /boot/ (or /efi/) mount
#   point is non-empty, no mount units are generated.
# aconfmgr doesn't track directories when all the contents are ignored, so this
# is actually commented out
# CreateDir /efi

# Add mount timeout check the automount timeout option
CopyFile /etc/systemd/system/efi.automount.d/idletimeout.conf
CopyFile /etc/systemd/system/efi.mount.d/permission.conf
# Enable periodic fstrim
SystemdEnable util-linux /usr/lib/systemd/system/fstrim.timer


# Now we config following the bootup sequence.
# To boot the system, we use systemd-boot that comes with systemd.
# It is simple enough for server usage.
# MANUAL: install bootloader to disk `bootctl install`
SystemdEnable systemd /usr/lib/systemd/system/systemd-boot-update.service

# We use stock Archlinux kernel with intel ucode upgrades
AddPackage linux-lts
AddPackage intel-ucode

# The bootloader loads unified kernel image (UKI)
AddRole initramfs-dracut
CreateLink /etc/pixmaps/oemlogo.bmp /usr/share/systemd/bootctl/splash-arch.bmp
CopyFile /etc/dracut.conf.d/unused-modules.conf
## Load nvme kernel module even we don't install nvme-cli package
CopyFile /etc/dracut.conf.d/nvme.conf
## Make sure btrfs is included
AddPackage btrfs-progs # Btrfs filesystem utilities
CopyFile /etc/dracut.conf.d/btrfs.conf
## Make sure usb keyboard is usable early on
CopyFile /etc/dracut.conf.d/force-usb-keyboard.conf

## For wireless connection, iwd is used
## MANUAL: connect and save wifi password
AddPackage linux-firmware
AddPackage iwd
SystemdEnable iwd /usr/lib/systemd/system/iwd.service
### Ignore iwd configs which is host specific
IgnorePath '/etc/iwd'
IgnorePath '/etc/iwd/*'

## Then systemd-networkd and systemd-resolvd are used to manage the interfaces.
AddRole network-systemd
## Connectivity of the host itself
CopyFile /etc/systemd/network/15-wired.network
CopyFile /etc/systemd/network/25-wireless.network
## The network setup is a little bit involved: VMs are connected to VLAN 2.
## VMs are on a bridged network, where the uplink of the bridge is a vlan
## subinterface of the main ethernet interface.
### Create the vlan subinterface for iot
CopyFile /etc/systemd/network/11-iot.netdev
### Create the bridge
CopyFile /etc/systemd/network/10-kvmbr0.netdev
### Also give the bridge an IP address on the IoT network, so the host can
### access IoT devices directly
CopyFile /etc/systemd/network/25-kvmbr0.network
### Connect iot interface to bridge
CopyFile /etc/systemd/network/20-iot-kvmbr0.network

# The last thing is to setup pacman and install packages for AUR
AddRole packaging

# Disable gnupg agents on server, we will rely on gpg agent forwarding via SSH
SystemdMask gpg-agent.service user
SystemdMask gpg-agent.socket user
SystemdMask gpg-agent-ssh.socket user
SystemdMask gpg-agent-browser.socket user
SystemdMask gpg-agent-extra.socket user

# Now the system boots, we stop here and leave further complex setups after reboot
## MANUAL: remember to run locale-gen
IsBootstrap && return 0

# Further networking configurations

# The server will join the zerotier-one network
AddRole zerotier

# And reachable via ssh
AddRole ssh

# Disk management
AddPackage smartmontools
SystemdEnable smartmontools /usr/lib/systemd/system/smartd.service
## Configure smartd monitoring
CopyFile /etc/smartd.conf
## Use s-nail to send mail when smartd finds an error
AddPackage s-nail # for sending email
### Configured sending via master@unlimited-code.works using gmail
CopyFile /etc/mail.rc 600
### smartd by default will not select account
CopyFile /usr/local/bin/smartd-mail 755

# Temp management
AddPackage lm_sensors
## System specific sensor module loading
CopyFile /etc/conf.d/lm_sensors
SystemdEnable lm_sensors /usr/lib/systemd/system/lm_sensors.service

# Additional userspace configurations

# Many familiar cli tools
AddRole rich-cli

# Rust is a must on any system, especially for rust-scripts
AddRole rust-dev

# Mount multiple disks here
AddRole nas

# Samba service
AddRole samba

# Windows VM
AddRole kvm
AddRole kvm-homelab

# Rest of the machine will be managed by k8s
AddRole k8s
## This server is a worker
cat >$(CreateFile /etc/conf.d/k3s) <<EOF
K3S_URL=https://aetf-arch-vps.zt.unlimited-code.works:6443
K3S_ARGS=agent
EOF
cat >$(CreateFile /etc/rancher/k3s/config.yaml) <<EOF
---
kubelet-arg: []

# cluster
token-file: /etc/rancher/k3s/ucw.token

# agent networking
node-ip: 10.144.180.10
node-external-ip: 192.168.80.238
flannel-iface: ztqu3dzpfj
EOF

# FUTURE: there's no fan driver for the motherboard yet

# Hardware quirks
AddRole fwupd

# Intel GPU
AddPackage intel-gpu-tools


# Thunderbolt userspace management tools
## No need to enable its systemd service, it will be activated by dbus
## automatically.
AddPackage bolt # Thunderbolt 3 device manager

# The Samsung 980 EVO NVME SSD constantly report 84C high temp warning on one
# sensor. The report is likely false alarms.
# See https://us.community.samsung.com/t5/Monitors-and-Memory/SSD-980-heat-spikes-to-84-C-183-F/td-p/2002779
# It is reported that this is related to power saving mode and the following
# kernel parameter can somehow reduce the frequency the issue happens by
# preventing SSD from entering nvme power management state autonomously.
echo "nvme_core.default_ps_max_latency_us=1500" \
    >$(CreateFile /etc/kernel/cmdline.d/samsung-evo-980-84c-fix.conf)
AddPackage nvme-cli
# nvme generated files
IgnorePath '/etc/nvme/*'

# APC UPS
AddPackage apcupsd
SystemdEnable apcupsd /usr/lib/systemd/system/apcupsd.service

# Misc apps
AddPackage qbittorrent-nox git-crypt nethogs
SystemdEnable --name qbittorrent-nox@aetf.service qbittorrent-nox /usr/lib/systemd/system/qbittorrent-nox@.service
cat >$(CreateFile /etc/systemd/system/qbittorrent-nox@aetf.service.d/override.conf) <<EOF
[Service]
Environment=QBT_WEBUI_PORT=9876
EOF

# As a volunteer for distcc
AddPackage distcc
CopyFile /etc/conf.d/distccd
SystemdEnable --name distccd.service distcc /usr/lib/systemd/system/distccd.service

# podman
AddRole docker
