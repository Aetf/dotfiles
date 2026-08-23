MatchHost || return 0

# This host serves as the homelab server in house, acting as the k8s cluster's
# control-plane (embedded etcd).
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

# Root mount options. There is no fstab entry on this host, so the only place
# to set these is a drop-in over the -.mount unit that
# systemd-gpt-auto-generator produces. Options= replaces the string rather
# than appending, so the generator's own ro,nodev,suid,exec are restated.
#
# noatime: this host runs k3s/containerd plus a root and a rootless podman
# store, so small-file reads are constant. Under relatime such a read dirties
# the inode, and on btrfs a dirty inode is a COW metadata write.
cat >$(CreateFile /etc/systemd/system/-.mount.d/noatime.conf) <<EOF
[Mount]
Options=ro,nodev,suid,exec,noatime
EOF

# Background reclaim of under-used btrfs data block groups. Both knobs are 0
# (off) by default, and with reclaim off, freed space stays trapped inside
# partly-filled data chunks instead of returning to Device unallocated. Once
# unallocated reaches zero the metadata block groups can no longer grow and
# the filesystem hard-ENOSPCs -- df still reports free space at that point,
# because that space is real but unreachable.
#
# periodic_reclaim has the kernel revisit under-used data block groups in the
# background; bg_reclaim_threshold is the used-percentage below which a block
# group is a candidate. The threshold is fixed: dynamic_reclaim, which would
# let the kernel retune it against observed reclaim success, is left off. 75
# therefore trades relocation IO for headroom unconditionally, and the
# reclaim_{count,bytes,errors} counters next to these knobs are the way to
# tell whether that trade is worth it -- lower to 50 if the IO is felt.
#
# Globbed over the fsid so a disk replacement cannot silently drop it.
cat >$(CreateFile /etc/tmpfiles.d/btrfs-reclaim.conf) <<EOF
w /sys/fs/btrfs/*/allocation/data/bg_reclaim_threshold - - - - 75
w /sys/fs/btrfs/*/allocation/data/periodic_reclaim - - - - 1
EOF


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

AddPackage linux-firmware

## This host is wired-only and has no WiFi stack: no iwd, no wl* .network.
## The one WiFi card, an AX210 at 05:00.0, belongs to the HAOS guest as the
## ua-WifiBluetoothCard hostdev. That hostdev is managed='yes', so libvirt
## hands the card back to the host driver every time the guest stops. Left to
## itself the host then associates and takes a DHCP lease under the same
## hostname the wired link uses, and the UDM -- which derives its home.arpa
## records from DHCP hostnames -- repoints aetf-arch-homelab.home.arpa (and
## the nas.home.arpa CNAME that Samba clients resolve through) at an address
## that dies the moment the guest starts again. Blacklisting the driver is
## what makes the handback inert; dropping iwd alone would not.
CopyFile /etc/modprobe.d/no-wifi.conf

## Then systemd-networkd and systemd-resolvd are used to manage the interfaces.
AddRole network-systemd
## Connectivity of the host itself
CopyFile /etc/systemd/network/15-wired.network
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
AddPackage gnupg
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
### Configured sending via master@unlimited-code.works using gmail.
### The account definition with credentials lives in a separate git-crypted
### drop-in, since this script itself is not encrypted (mail.rc is sourced by
### any user running mail, so the drop-in is 640 root:aetf for smartd + check-hath).
cat >> "$(GetPackageOriginalFile s-nail /etc/mail.rc)" <<EOF
# Required since s-nail 14.9.25 for the new-style smtp:// mta URL
set v15-compat
source /etc/mail.d/google.rc
EOF
CopyFile /etc/mail.d/google.rc 640 root aetf
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

# HackRF One, driving the fireplace remote over 315 MHz
AddRole sdr

# Mount multiple disks here
AddRole nas

# Samba service
AddRole samba

# Windows VM
AddRole kvm
AddRole kvm-homelab

# Rest of the machine will be managed by k8s
AddRole k8s
## This host is the cluster server (took over from aetf-arch-vps, which is now
## an agent), so /etc/conf.d/k3s agent env vars are no longer needed.
cat >$(CreateFile /etc/rancher/k3s/config.yaml) <<EOF
---
# k3s deployment
write-kubeconfig-mode: "644"
disable:
- traefik
- local-storage

# Use embedded etcd.
# This also migrates from existing single-node sqlite
cluster-init: true

kubelet-arg: []
kube-controller-manager-arg:
  - "node-monitor-grace-period=120s"
  - "node-monitor-period=10s"

# =====================
# api server networking
# =====================
bind-address: 10.144.180.10
advertise-address: 10.144.180.10
# additional IP to add in TLS cert
tls-san:
- 10.144.180.10
- aetf-arch-homelab.zt.unlimited-code.works

# =====================
# agent networking
# =====================
#node-ip: 10.144.160.212
node-ip: 10.144.180.10
#node-external-ip: 45.77.144.92
node-external-ip: 192.168.80.238
flannel-iface: ztqu3dzpfj
# server only
flannel-backend: host-gw
EOF
cat >$(CreateFile /etc/systemd/system/k3s.service.d/override.conf) <<EOF
[Unit]
# Several NodePVs (media-pv, sync-nas-pv, hath-pv, immich-pv) bind-mount
# directories under /mnt/nas into pods. Without this ordering k3s can win
# the boot race against zfs mounting (zfs-mount-generator provides
# mnt-nas.mount) and kubelet would bind-mount empty directories into pods
# -- same race qbittorrent-nox hit on the 2026-07-02 boot.
RequiresMountsFor=/mnt/nas
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
AddPackage claude-code # An agentic coding tool that lives in your terminal
SystemdEnable --name qbittorrent-nox@aetf.service qbittorrent-nox /usr/lib/systemd/system/qbittorrent-nox@.service
cat >$(CreateFile /etc/systemd/system/qbittorrent-nox@aetf.service.d/override.conf) <<EOF
[Unit]
# Torrent data lives on the ZFS pool. Without this ordering the service can
# win the boot race against zfs mounting (zfs-mount-generator provides
# mnt-nas.mount) and flag every torrent as missingFiles, which happened on
# the 2026-07-02 boot (438 of 443 torrents).
RequiresMountsFor=/mnt/nas

[Service]
Environment=QBT_WEBUI_PORT=9876
Environment=QBT_WEBUI_ADDRESS='*'
StateDirectory=qBittorrent
ExecStart=
ExecStart=/usr/bin/qbittorrent-nox --profile=/var/lib/qBittorrent --relative-fastresume
EOF

# As a volunteer for distcc
AddPackage distcc
CopyFile /etc/conf.d/distccd
SystemdEnable --name distccd.service distcc /usr/lib/systemd/system/distccd.service

# podman
AddRole docker

# Remote log sink
AddRole remote-log-sink

# Jellyfin discovery relay
CopyFile /etc/systemd/system/jellyfin-discovery-relay.service
SystemdEnable --from-file /etc/systemd/system/jellyfin-discovery-relay.service

# Samsung TV relay, bridging Home Assistant to the TV across VLANs
# (socat comes from the rich-cli role)
CopyFile /etc/systemd/system/samsung-tv-relay.service
SystemdEnable --from-file /etc/systemd/system/samsung-tv-relay.service

# chored: Home Assistant runs declared jobs here (TV app installs, later
# mail tasks) over a forced-command SSH key. Jobs live in
# ~/.config/chored/jobs.d (yadm); the AUR package is ours (~/packages).
AddPackage --foreign chored

# qemu binfmt.d
CopyFile /etc/binfmt.d/qemu-aarch64-static.conf
CopyFile /etc/binfmt.d/qemu-aarch64_be-static.conf
CopyFile /etc/binfmt.d/qemu-arm-static.conf
CopyFile /etc/binfmt.d/qemu-armeb-static.conf


AddPackage github-cli
AddPackage google-cloud-cli
AddPackage aws-cli-v2
AddPackage immich-go
AddPackage uv
