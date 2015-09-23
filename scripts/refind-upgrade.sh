#! /bin/sh

function mountPathForBoot() {
    findmnt -n -o SOURCE -T /boot | sed -r 's/^.*\[(.*)\].*$/\1/'
}

#echo "Umount anything on /boot"
#while umount /boot; do continue; done

echo "Mount ESP on /boot"
mount -o bind /esp /boot

echo "Install refind"
/usr/bin/refind-install

echo "Restore /boot previous mount status"
umount /boot
#mount -o bind /esp/EFI/archlinux /boot

echo "Remove unneeded conf file"
rm -f /esp/*.conf
if diff -q /esp/EFI/refind/icons /esp/EFI/refind/icons-backup > /dev/null; then
    echo "Remove identical icons-backup"
    rm -rf /esp/EFI/refind/icons-backup
fi
