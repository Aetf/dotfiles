
AddPackage samba # SMB Fileserver and AD Domain server
CopyFile /etc/samba/smb.conf

IgnorePath '/etc/samba/credentials/*'
