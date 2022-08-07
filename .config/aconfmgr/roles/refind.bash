AddPackage refind-git # rEFInd Boot Manager - git version (Aetf fixed)

# Automatically update refind in ESP after package changes
CopyFile /etc/pacman.d/hooks/refind.hook

# This script will ensure the ESP partition is mounted, and then
# call `refind-install` to install rEFInd.
CopyFile /usr/local/bin/refind-upgrade 755

# Additionally, any files here will be copied over to the rEFInd
# directory in ESP during `refind-upgrade`
CreateDir /etc/refind.d/overlay/
