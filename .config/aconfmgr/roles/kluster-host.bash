# Host preparation for the kluster physical stack
# (kluster docs/physical/homelab-host.md §4). This role carries the part
# that exists so far: the dedicated service user the pulumi-libvirt
# provider connects as over qemu+ssh. libvirt-group membership is
# root-equivalent in effect (domain XML can map any host device), so the
# account carries nothing else: no other groups, no password, one key.
# P4 extends this role with the second bridge, the nodatacow subvolume
# and the storage pool.

cat > "$(CreateFile /etc/sysusers.d/kluster-virt.conf)" <<SYSUSERS
u virt - "kluster libvirt service user" /home/virt /bin/sh
m virt libvirt
SYSUSERS

CreateDir /home/virt 700 virt virt
CreateDir /home/virt/.ssh 700 virt virt
cat > "$(CreateFile /home/virt/.ssh/authorized_keys 600 virt virt)" <<KEYS
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE+R1pe61Q5SY2yPX2TSih7b7ZgQsWlXggjWNPN1652H kluster-physical@libvirt
KEYS
