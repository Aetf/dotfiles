# Homelab specific kvm settings, pulled out to separated file due to complexity

## We don't want the default NAT network, and we don't install dependencies for
## it anyway. Tell pacman to not extract it
cat >$(CreateFile /etc/pacman.d/confs/no-libvirt-default-net.conf) <<EOF
# No libvirt default NAT network as we don't install its dependencies anyway.
[options]
NoExtract = etc/libvirt/qemu/networks/default.xml
EOF

# Domain definitions are libvirt's own state, not configuration: virsh edit
# and managed migrations rewrite them, and the HAOS domain is adopted by the
# kluster physical stack (Pulumi import by UUID). Declaring the XML here would
# put two owners on one file, so the whole directory is ignored instead
# (see 10-ignores.sh).
