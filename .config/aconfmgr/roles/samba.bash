# Use kernel space ksmbd server

AddPackage --foreign ksmbd-tools # Userspace tools for the ksmbd kernel SMB server

# Create the common share directory
CreateDir /srv/share "0755" 1000 1000
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
