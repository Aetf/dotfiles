# Host preparation for the kluster physical stack
# (kluster docs/physical/homelab-host.md §4). This role carries the part
# that exists so far: the dedicated service user the pulumi-libvirt
# provider connects as over qemu+ssh. libvirt-group membership is
# root-equivalent in effect (domain XML can map any host device), so the
# account carries nothing else: no other groups, no password, one key.
# P4 extends this role with the second bridge, the nodatacow subvolume
# and the storage pool.
#
# Only /etc files are managed here: sysusers creates users but never
# their homes, and the companion mechanism for those is tmpfiles.d —
# ordered after sysusers at boot, so the virt owner always resolves.
# (aconfmgr installing a virt-owned path directly fails on a host where
# the user does not exist yet.) First activation without a reboot:
#   sudo systemd-sysusers && sudo systemd-tmpfiles --create

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
