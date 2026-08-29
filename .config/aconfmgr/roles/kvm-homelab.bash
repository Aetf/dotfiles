# Homelab specific kvm settings, pulled out to separated file due to complexity

## We don't want the default NAT network, and we don't install dependencies for
## it anyway. Tell pacman to not extract it
cat >$(CreateFile /etc/pacman.d/confs/no-libvirt-default-net.conf) <<EOF
# No libvirt default NAT network as we don't install its dependencies anyway.
[options]
NoExtract = etc/libvirt/qemu/networks/default.xml
EOF

## HAOS domain (UUID 5e10948c-8934-4239-849c-b6b9104bfe3f). This declaration
## is the domain's single owner: the kluster physical stack deliberately does
## not manage libvirt domains (RFC-002 §13), so nothing else defines it.
## The disk image lives under the nodatacow subvolume /var/lib/libvirt/kluster
## (created by tmpfiles, see roles/kluster-host.bash). Recreation on a fresh
## host = `virsh define` of this file. Intentional changes go through
## `virsh edit` first, then are captured back here.
CopyFile /etc/libvirt/qemu/haos.xml 600
## Autostart
CreateLink /etc/libvirt/qemu/autostart/haos.xml /etc/libvirt/qemu/haos.xml
