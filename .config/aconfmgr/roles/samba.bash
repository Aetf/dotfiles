# Use kernel space ksmbd server

AddPackage $FOREIGN ksmbd-tools # Userspace tools for the ksmbd kernel SMB server
SystemdEnable ksmbd-tools /usr/lib/systemd/system/ksmbd.service

# Create the common share directory
cat >$(CreateFile /srv/share/README.md) << EOF
# Common Share Directory
The content in this directory is by default shared in samba
EOF
## Ignore any files one level below
IgnorePath /srv/share/*/*

cat >$(CreateFile /etc/ksmbd/smb.conf) <<EOF
[nas]
    path = /srv/share
    read only = no
    force user = aetf
    force group = aetf
EOF

# Need create ksmbd user manually afterwards
# MANUAL: ksmbd.adduser -a aetf
IgnorePath '/etc/ksmbd/ksmbdpwd.db'
IgnorePath '/etc/ksmbd/ksmbd.subauth'
