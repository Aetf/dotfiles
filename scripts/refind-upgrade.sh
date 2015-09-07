#! /bin/sh

# Make sure /boot isn't a mount point
umount /boot || true

# Mount ESP on /boot
mount /dev/disk/by-uuid/67E3-17ED /boot

# Install refind
/usr/bin/refind-install

# Restore /boot bind to /esp
umount /boot
mount --bind /esp/EFI/archlinux /boot

# Remove unneeded conf file
rm /esp/*.conf
