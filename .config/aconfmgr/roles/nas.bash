# Our zfs based NAS setup

# zfs related setup
AddPackage $FOREIGN zfs-utils
AddPackage zfs-linux-lts

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
# MANUAL: sudo zpool create -o ashift=12 -m /mnt/nas nas raidz2 /dev/disk/by-id/ata-ST8000VN004-3CP101_WWZ1KD44 /dev/disk/by-id/ata-ST8000VN004-3CP101_WWZ1PHHH /dev/disk/by-id/ata-ST8000VN004-3CP101_WWZ1Q6M8 /dev/disk/by-id/ata-ST8000VN004-3CP101_WWZ1Q7SB
# MANUAL: auto mount cache: mkdir /etc/zfs/zfs-list.cache && touch /etc/zfs/zfs-list.cache/nas && zfs set canmount=on nas

# For hdparm
AddPackage hdparm
