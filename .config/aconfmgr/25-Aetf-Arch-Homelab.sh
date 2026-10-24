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
# background. dynamic_reclaim derives the used-percentage below which a block
# group gets relocated from how short Device unallocated is of a 10-chunk
# target: 0 (no relocation at all) while unallocated holds 10 chunks or more,
# rising as it drains. The same threshold gates both the periodic sweep and
# the relocate-on-free path (btrfs_calc_reclaim_threshold in 6.18), and
# bg_reclaim_threshold is ignored while dynamic_reclaim is on.
#
# A fixed threshold is the wrong shape for this disk. It relocates every
# block group that drops below it on free, whatever the headroom, so a large
# delete (image GC, a pacman cache sweep) turns into a relocation storm; on
# the DRAM-less 980 a storm of ~3000 write IOPS took average write latency
# from 2 ms to ~95 ms, which is the latency the k3s data on this disk cannot
# ride out. Reclaim is only worth its IO when unallocated is actually short.
# reclaim_{count,bytes,errors} next to these knobs show what it does.
#
# Globbed over the fsid so a disk replacement cannot silently drop it.
cat >$(CreateFile /etc/tmpfiles.d/btrfs-reclaim.conf) <<EOF
w /sys/fs/btrfs/*/allocation/data/dynamic_reclaim - - - - 1
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
## The one WiFi card, an AX210 at 09:00.0, belongs to the HAOS guest as the
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

## Instrumentation for an intermittent boot-time resolved fault (systemd 262):
## /run/systemd/resolve/resolv.conf -- kubelet's resolv.conf, so CoreDNS's
## upstream -- gets written with "No DNS servers known" while networkd has
## already published the DHCP servers, and is not rewritten after resolved
## learns them. Debug logging plus a per-second trace of the first minutes after
## boot show when resolved's in-memory servers and the written file diverge.
## Remove this whole block once a faulty boot has been captured.
cat >$(CreateFile /etc/systemd/system/systemd-resolved.service.d/debug-log.conf) <<'EOF'
[Service]
Environment=SYSTEMD_LOG_LEVEL=debug
EOF
cat >$(CreateFile /usr/local/bin/resolved-boot-trace 755) <<'EOF'
#!/bin/sh
# Once a second for the first minutes after boot, record what resolved holds in
# memory against what it last wrote to the uplink resolv.conf, alongside
# networkd's per-link state files; link/address events are logged as they
# happen. Output: /var/log/resolved-boot-trace/<boot id>/.
dir=/var/log/resolved-boot-trace/$(cat /proc/sys/kernel/random/boot_id)
mkdir -p "$dir"
timeout 240 ip -ts -o monitor link address > "$dir/ip-monitor.log" 2>&1 &
end=$(( $(cut -d. -f1 /proc/uptime) + 240 ))
while [ "$(cut -d. -f1 /proc/uptime)" -lt "$end" ]; do
    f=/run/systemd/resolve/resolv.conf
    echo "== uptime $(cut -d' ' -f1 /proc/uptime)"
    echo "file mtime=$(stat -c %y "$f" 2>/dev/null) nameservers=$(grep -c '^nameserver' "$f" 2>/dev/null)"
    for l in /run/systemd/netif/links/*; do
        echo "netif $(basename "$l") mtime=$(stat -c %y "$l") $(grep -E '^(ADMIN_STATE|OPER_STATE|DNS)=' "$l" | tr '\n' ' ')"
    done
    resolvectl dns 2>&1 | grep -E ':.*[0-9]'
    sleep 1
done > "$dir/trace.log" 2>&1
wait
EOF
cat >$(CreateFile /etc/systemd/system/resolved-boot-trace.service) <<'EOF'
[Unit]
Description=Trace systemd-resolved DNS state for the first minutes after boot
After=systemd-resolved.service dbus.socket
Wants=systemd-resolved.service

[Service]
Type=simple
ExecStart=/usr/local/bin/resolved-boot-trace

[Install]
WantedBy=multi-user.target
EOF
SystemdEnable --from-file /etc/systemd/system/resolved-boot-trace.service

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
## kluster's libvirt session (the `physical` stack) dials this host over the
## overlay on port 22: pulumi-libvirt 0.5.4 wraps terraform-provider-libvirt
## v0.8.1, whose qemu+ssh dial mangles a port given in the URI (upstream
## dmacvicar/terraform-provider-libvirt#1116, fixed in v0.8.3). So sshd also
## listens on 22, on the overlay address alone; 59901 stays the main port. Once
## a pulumi-libvirt release carries the fix, kluster dials 59901 and this goes
## (Aetf/kluster-ops#519). Naming any ListenAddress turns off `Port`'s
## all-address default, so 59901 is listed explicitly for both families.
cat >"$(CreateFile /etc/ssh/sshd_config.d/overlay-port-22.conf)" <<EOF
ListenAddress 10.144.180.10:22
ListenAddress 0.0.0.0:59901
ListenAddress [::]:59901
EOF
## sshd starts before ZeroTier assigns 10.144.180.10, and a bind to an address
## the host does not hold yet fails and is not retried. Allowing a non-local
## bind holds the listener from boot; it carries traffic once the address
## exists. Waiting for ZeroTier instead would make sshd depend on the overlay.
cat >"$(CreateFile /etc/sysctl.d/60-nonlocal-bind.conf)" <<EOF
net.ipv4.ip_nonlocal_bind = 1
EOF

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
CopyFile /etc/mail.d/google.rc 640 "" aetf
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

# The four 8T disks that used to form raidz2-0 of the nas pool stay in the
# JBOD out of any pool. The enclosure cannot power individual bays off, so
# they spin down after 30 minutes idle (hdparm -S 241) instead of wearing and
# heating the enclosure for nothing. Matched by serial so the rule never
# touches a disk that is in use.
cat >$(CreateFile /etc/udev/rules.d/69-idle-disk-spindown.rules) <<'EOF'
ACTION=="add|change", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", ENV{ID_SERIAL}=="ST8000VN004-3CP101_WWZ1KD44|ST8000VN004-3CP101_WWZ1PHHH|ST8000VN004-3CP101_WWZ1Q6M8|ST8000VN004-3CP101_WWZ1Q7SB", RUN+="/usr/bin/hdparm -S 241 /dev/%k"
EOF

# The fast pool: a single-disk ZFS pool on the PM983 (enterprise NVMe with
# DRAM and power-loss protection, so a cache flush is close to free) that
# holds the latency-sensitive k3s state, the embedded etcd and the local-path
# PVs (cnpg databases, prometheus, app configs). Nothing else writes to this
# disk. The root btrfs on the DRAM-less 980 takes every other write burst
# (build output, image pulls, pacman, block group relocation), and any of
# those used to push etcd fdatasync into the seconds and make k3s exit.
#
# ZFS rather than fixed partitions: space between the datasets moves by
# setting quota/reservation, in both directions, with no repartitioning. k3s
# already cannot start without ZFS (the nas pool), so this is no new failure
# mode. Datasets:
# - fast/etcd, mounted at the k3s etcd data dir. Its reservation holds etcd's
#   space whatever the PVs do: local-path enforces no size, so a runaway PV
#   can fill fast/storage up to the pool but never into etcd's share.
# - fast/storage, mounted at /mnt/storage, whose k8s-storage/ is the
#   local-path PV root (kluster-code src/local-path). Same layout as
#   aetf-arch-vps, where /mnt/storage is also a separate disk, and PV
#   hostPaths stay valid across the move.
# recordsize=16K fits the page-sized random writes of bbolt and postgres.
# acltype/xattr=sa let rsync -aHAX carry ACLs and xattrs over faithfully.
# IOWeight= does nothing here: ZFS issues writes from its own kernel threads,
# so cgroup io accounting never sees them. Isolation comes from the disk.
# The last ~34 GiB of the disk stay unpartitioned as room for a possible SLOG
# for the nas pool. A vdev cannot shrink, so that room is set aside up front.
# MANUAL: printf 'label: gpt\nsize=860GiB, type=6A898CC3-1DD2-11B2-99A6-080020736631, name=fast\n' | sfdisk /dev/disk/by-id/nvme-SAMSUNG_MZ1LB960HAJQ-00007_S435NA0MA12910
# MANUAL: touch /etc/zfs/zfs-list.cache/fast && zpool create -o ashift=12 -o autotrim=on -O compression=lz4 -O atime=off -O acltype=posix -O xattr=sa -O recordsize=16K -O mountpoint=none fast /dev/disk/by-id/nvme-SAMSUNG_MZ1LB960HAJQ-00007_S435NA0MA12910-part1
# MANUAL: zfs create -o mountpoint=/var/lib/rancher/k3s/server/db -o reservation=8G fast/etcd
# MANUAL: zfs create -o mountpoint=/mnt/storage fast/storage
SystemdEnable --name zfs-scrub-monthly@fast.timer zfs-utils /usr/lib/systemd/system/zfs-scrub-monthly@.timer

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
# Leader election is a liveness check against the local apiserver, and losing
# it is fatal: k3s exits as a whole, taking kubelet and the apiserver down with
# it. On this single-server cluster the lease has nothing to arbitrate, so the
# upstream 15s/10s budget only turns an etcd stall (its disk saturated, as
# the root 980 was before etcd moved to the fast pool) into a full restart --
# which is itself an IO burst. 60s/40s rides out a stall; a real deadlock still
# trips it. All three elected components must agree or the strictest one
# still exits the process.
kube-controller-manager-arg:
  - "node-monitor-grace-period=120s"
  - "node-monitor-period=10s"
  - "leader-elect-lease-duration=60s"
  - "leader-elect-renew-deadline=40s"
kube-scheduler-arg:
  - "leader-elect-lease-duration=60s"
  - "leader-elect-renew-deadline=40s"
kube-cloud-controller-manager-arg:
  - "leader-elect-lease-duration=60s"
  - "leader-elect-renew-deadline=40s"

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
# /var/lib/scratch is the nas/scratch dataset behind the local-path-scratch
# StorageClass (kluster-code src/local-path): same race, and worse, a miss
# would land CI runner scratch on the root nvme -- the disk this class
# exists to keep them off.
# The etcd data dir and /mnt/storage are datasets of the fast pool (see
# above). Starting without them is the worst of these misses: k3s would find
# an empty etcd dir and, with cluster-init, bootstrap a brand-new empty
# cluster, and the local-path PVs would come up empty.
RequiresMountsFor=/mnt/nas /var/lib/scratch /var/lib/rancher/k3s/server/db /mnt/storage
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
AddRole claude-code
CopyFile /etc/claude-code/managed-settings.d/20-homelab.json
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

# kluster physical stack host prep (libvirt service user; P4 adds the rest)
AddRole kluster-host

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
AddPackage $FOREIGN chored

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
