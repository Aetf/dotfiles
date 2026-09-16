AddPackage $FOREIGN k3s-1.34-bin
AddPackage kubectl
AddPackage cmctl
SystemdEnable k3s-1.34-bin /usr/lib/systemd/system/k3s.service

# The embedded etcd shares its disk with every pod's emptyDir and container
# layers, and a tenant writing at full speed pushes etcd fdatasync into the
# seconds: the controllers lose their leases and k3s exits as a whole. The
# weight puts k3s ahead of everything else in system.slice (system.slice
# already splits the device evenly with kubepods.slice at the root), and the
# ExecStartPre turns on io.cost for the disk behind the data dir, without
# which the weight means nothing on an nvme under the "none" scheduler. The
# script explains why only enable=1 is written.
CopyFile /usr/local/bin/k3s-iocost-enable 755
cat >$(CreateFile /etc/systemd/system/k3s.service.d/io-priority.conf) <<EOF
[Service]
IOWeight=1000
ExecStartPre=-/usr/local/bin/k3s-iocost-enable
EOF

# Node feature isn't configuration
IgnorePath /etc/kubernetes/node-feature-discovery/*

# Tokens are private
IgnorePath /etc/rancher/k3s/*.token

# Juicefs volume plugin isn't isolated and will create this
IgnorePath /etc/updatedb.conf
