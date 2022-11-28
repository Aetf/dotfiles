# Use kernel space ksmbd server

AddPackage $FOREIGN ksmbd-tools # Userspace tools for the ksmbd kernel SMB server
SystemdEnable ksmbd-tools /usr/lib/systemd/system/ksmbd.service

cat >$(CreateFile /etc/ksmbd/ksmbd.conf) <<EOF
[nas]
    path = /mnt/nas
    read only = no
    force user = aetf
    force group = aetf
EOF

# Need create ksmbd user manually afterwards
# MANUAL: ksmbd.adduser -a aetf
IgnorePath '/etc/ksmbd/ksmbdpwd.db'
IgnorePath '/etc/ksmbd/ksmbd.subauth'
