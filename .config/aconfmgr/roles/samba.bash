
AddPackage samba # SMB Fileserver and AD Domain server
CopyFile /etc/samba/smb.conf '' aetf aetf

IgnorePath '/etc/samba/credentials/*'
