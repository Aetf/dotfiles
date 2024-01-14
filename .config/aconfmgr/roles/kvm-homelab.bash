# Homelab specific kvm settings, pulled out to separated file due to complexity

## We don't want the default NAT network, and we don't install dependencies for
## it anyway. Tell pacman to not extract it
cat >$(CreateFile /etc/pacman.d/confs/no-libvirt-default-net.conf) <<EOF
# No libvirt default NAT network as we don't install its dependencies anyway.
[options]
NoExtract = etc/libvirt/qemu/networks/default.xml
EOF

CopyFile /etc/libvirt/qemu/haos.xml 600
## Autostart
CreateLink /etc/libvirt/qemu/autostart/haos.xml /etc/libvirt/qemu/haos.xml
