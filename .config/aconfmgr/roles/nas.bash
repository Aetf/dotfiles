# Our zfs based NAS setup

# Disk enclosure setup
CopyFile /etc/udev/rules.d/92-scsi-sg.rules
AddPackage lsscsi
AddPackage sg3_utils
AddPackage $FOREIGN ledmonutils

# zfs related setup
AddPackage linux-lts-headers
AddPackage $FOREIGN zfs-utils
AddPackage zfs-dkms

# Disable dracut zfs boot module as we don't boot with that,
# also the module makes the system unbootable due to a missing service file
# See openzfs/zfs#13573 and openzfs/zfs#13574
echo 'omit_dracutmodules+=" zfs "' > "$(CreateFile /etc/dracut.conf.d/no-zfs.conf)"

# Automatic import of zfs pools
SystemdEnable zfs-utils /usr/lib/systemd/system/zfs-import-cache.service
SystemdEnable zfs-utils /usr/lib/systemd/system/zfs-import.target

# Automatic mount using zfs-mount-generator(8)
SystemdEnable zfs-utils /usr/lib/systemd/system/zfs-zed.service
SystemdEnable zfs-utils /usr/lib/systemd/system/zfs.target
## Make zed use standard direcotry path
cat >$(CreateFile /etc/systemd/system/zfs-zed.service.d/std-path.conf) <<'EOF'
[Service]
RuntimeDirectory=zed
StateDirectory=zed
ExecStart=
ExecStart=/usr/bin/zed -F -s ${STATE_DIRECTORY}/zed.state -p ${RUNTIME_DIRECTORY}/zed.pid
EOF

# Periodic scrub
SystemdEnable --name zfs-scrub-monthly@nas.timer zfs-utils /usr/lib/systemd/system/zfs-scrub-monthly@.timer

# MANUAL: create pool and touch /etc/zfs/zfs-list.cache/<pool-name>
# ashift=12 sets the sector size to be 4k rather than 512B default.
# The pool is two 4-disk raidz2 vdevs (4x 16T, and 4x 14T of mixed models).
# autoexpand=on lets a vdev grow once all its disks are replaced with larger
# ones, so capacity is upgraded in place by `zpool replace`, one vdev at a time.
# MANUAL: sudo zpool create -o ashift=12 -o autoexpand=on -m /mnt/nas nas raidz2 /dev/disk/by-id/ata-ST16000NT001-3LV101_ZRS1ZC21 /dev/disk/by-id/ata-ST16000NT001-3LV101_ZRS1YF7Q /dev/disk/by-id/ata-ST16000NT001-3LV101_ZRS1WCQE /dev/disk/by-id/ata-ST16000NT001-3LV101_ZRS1WALC raidz2 /dev/disk/by-id/ata-ST14000NE0008-2JK101_ZHZ68JKA /dev/disk/by-id/ata-ST14000NE0008-2JK101_ZHZ68JNJ /dev/disk/by-id/ata-ST14000NE0008-2RX103_QV1ZEBLA /dev/disk/by-id/ata-WDC_WD140EDGZ-11B1PA0_Y6G2MYYC
# MANUAL: auto mount cache: mkdir /etc/zfs/zfs-list.cache && touch /etc/zfs/zfs-list.cache/nas && zfs set canmount=on nas
#
# Datasets besides the pool root, with the properties that are not defaults.
# nas/scratch backs the k8s local-path-scratch StorageClass (kluster-code
# src/local-path): per-pod volumes a job may fill at full speed (CI runner
# image stores, cargo targets), kept off the root nvme that etcd lives on.
# local-path enforces no size, so the refquota is the only bound; it is
# mounted outside /mnt/nas because it is not NAS content and must not be
# exported or shared. k3s orders itself after this mount (see the host file).
# sync=disabled because everything on it is disposable: CI tools fsync
# heavily (uv installing interpreters, cargo's SQLite global cache), and each
# fsync is a ZIL commit that waits on a cache flush from every disk in the
# raidz2, so it goes at the pace of the slowest disk. With the WD140EDGZ in
# the pool, that stalled CI jobs for minutes with no output. Losing the last
# few seconds of writes on a crash is fine for data that is thrown away anyway.
# MANUAL: zfs create -o mountpoint=/var/lib/scratch -o refquota=50G -o compression=lz4 -o atime=off -o sync=disabled nas/scratch

# For hdparm
AddPackage hdparm

# Permission & Access

# Create a samba user group so the whole NAS can use one group
cat > "$(CreateFile /etc/sysusers.d/nas.conf)" <<EOF
g nas 10000
EOF

# Create access for Aetf
cat > "$(CreateFile /etc/sysusers.d/aetf-nas.conf)" <<EOF
m aetf nas
EOF

# Create access for Music Assistant
cat > "$(CreateFile /etc/sysusers.d/music_assistant.conf)" <<EOF
u! music_assistant - "Music Assistant Samba Access"
m music_assistant nas
EOF

# Create NFS setup
AddPackage nfs-utils # Support programs for Network File Systems
# 192.168.70.10 is the kluster worker VM on the cluster VLAN, scoped to
# that single host and reached through the host's own kvmbr1 leg.
cat > "$(CreateFile /etc/exports.d/nas.exports)" <<EOF
/mnt/nas 192.168.80.0/24(rw,async,no_subtree_check,all_squash,anonuid=1000,anongid=10000) 192.168.90.0/24(rw,async,no_subtree_check,all_squash,anonuid=1000,anongid=10000) 192.168.70.10(rw,async,no_subtree_check,all_squash,anonuid=1000,anongid=10000) fd1a:665f:8bcb::/48(rw,async,no_subtree_check,all_squash,anonuid=1000,anongid=10000)
EOF
SystemdEnable nfs-utils /usr/lib/systemd/system/nfs-server.service
