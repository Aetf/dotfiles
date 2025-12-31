# Use kernel space ksmbd server

#AddPackage $FOREIGN ksmbd-tools # Userspace tools for the ksmbd kernel SMB server
#SystemdEnable ksmbd-tools /usr/lib/systemd/system/ksmbd.service

# cat >$(CreateFile /etc/ksmbd/ksmbd.conf) <<EOF
# [global]
#     deadtime = 10
# [nas]
#     path = /mnt/nas
#     read only = no
#     force user = aetf
#     force group = aetf
# EOF

# Need to create ksmbd user manually afterwards
# MANUAL: ksmbd.adduser -a aetf
IgnorePath '/etc/ksmbd/ksmbdpwd.db'
IgnorePath '/etc/ksmbd/ksmbd.subauth'

# Usual samba package
AddPackage samba # SMB Fileserver and AD Domain server
CopyFile /etc/samba/smb.conf
SystemdEnable samba /usr/lib/systemd/system/smb.service

# Enable mDNS discovery of the service, depending on enabling of systemd-resolved
CopyFile /etc/systemd/dnssd/smb.dnssd

# Need to create samba user manually afterwards
# MANUAL: smbpasswd -a aetf
#IgnorePath '/etc/ksmbd/ksmbdpwd.db'
#IgnorePath '/etc/ksmbd/ksmbd.subauth'

