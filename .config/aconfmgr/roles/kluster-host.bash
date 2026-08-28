# Host preparation for the kluster physical stack
# (kluster docs/physical/homelab-host.md §4): the dedicated service user
# the pulumi-libvirt provider connects as over qemu+ssh, the cluster
# VLAN bridge with the host's leg on it, and the nodatacow subvolume
# holding the worker's disk image. The libvirt storage pool over that
# subvolume is not declared here — libvirt rewrites its own
# /etc/libvirt/storage XML, so the pool is defined at import time.
#
# libvirt-group membership is root-equivalent in effect (domain XML can
# map any host device), so the virt account carries nothing else: no
# other groups, no password, one key.
#
# Only /etc files are managed here: sysusers creates users but never
# their homes, and the companion mechanism for those is tmpfiles.d —
# ordered after sysusers at boot, so the virt owner always resolves.
# (aconfmgr installing a virt-owned path directly fails on a host where
# the user does not exist yet.) First activation without a reboot:
#   sudo systemd-sysusers && sudo systemd-tmpfiles --create
#   sudo networkctl reload

cat > "$(CreateFile /etc/sysusers.d/kluster-virt.conf)" <<SYSUSERS
u virt - "kluster libvirt service user" /home/virt /bin/sh
m virt libvirt
SYSUSERS

# `f` writes its argument only when it creates the file, so a live
# authorized_keys is never clobbered; sshd does not mind the missing
# trailing newline.
cat > "$(CreateFile /etc/tmpfiles.d/kluster-virt.conf)" <<TMPFILES
d /home/virt 0700 virt virt -
d /home/virt/.ssh 0700 virt virt -
f /home/virt/.ssh/authorized_keys 0600 virt virt - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE+R1pe61Q5SY2yPX2TSih7b7ZgQsWlXggjWNPN1652H kluster-physical@libvirt
TMPFILES

# The worker VM's network (homelab-host.md §2): VLAN 7 tagged on the
# physical NIC, bridged as kvmbr1, with a host leg at 192.168.70.2 so
# host<->worker NFS traffic stays on the box instead of hairpinning
# through the UDM. Same mechanism as the HAOS iot/kvmbr0 pair; enp7s0
# keeps its untagged address and the default route. 15-wired.network
# carries the matching VLAN= association.
CopyFile /etc/systemd/network/13-kluster.netdev
CopyFile /etc/systemd/network/12-kvmbr1.netdev
CopyFile /etc/systemd/network/21-kluster-kvmbr1.network
CopyFile /etc/systemd/network/26-kvmbr1.network

# The worker's disk image storage (homelab-host.md §1): a dedicated
# nodatacow subvolume, which also keeps the image out of any host
# snapshot/send scope. tmpfiles expresses both halves: `v` creates a
# btrfs subvolume where `d` would create a plain directory, and `h`
# sets +C on it — which governs files created inside from then on but
# never rewrites pre-existing ones (those need cp --reflink=never to a
# new file to actually shed CoW).
cat > "$(CreateFile /etc/tmpfiles.d/kluster-libvirt-storage.conf)" <<TMPFILES
v /var/lib/libvirt/kluster 0755 root root -
h /var/lib/libvirt/kluster - - - - +C
TMPFILES
