CopyFile /usr/local/bin/mount-esp 755
CopyFile /etc/pacman.d/hooks/ensure-vfat.hook

AddPackage dracut
AddOptionalPackage dracut \
    pigz 'faster gzip compression' `# Parallel implementation of the gzip file compressor`
CopyFile /etc/pacman.d/hooks/60-dracut-remove-uki.hook
CopyFile /etc/pacman.d/hooks/90-dracut-install-uki.hook
CopyFile /usr/local/bin/dracut-install-uki 755
CopyFile /usr/local/bin/dracut-remove-uki 755
CopyFile /etc/dracut.conf.d/defaults.conf
CopyFile /etc/dracut.conf.d/early-kms.conf

# Each file in these directory adds additional files to the uki
# The file format is one path per line, empty lines and those starting with `#` are ignored.
CreateDir /etc/dracut.conf.d/install.d/normal
CreateDir /etc/dracut.conf.d/install.d/fallback

CopyFile /etc/dracut.conf.d/cmdline.d/README


AddPackage mkmm # Moviuro's Kernel Module Manager
CreateLink /etc/pacman.d/hooks/10-mkmm-tmpfs-post.hook /usr/share/mkmm/10-mkmm-tmpfs-post.hook
CreateLink /etc/pacman.d/hooks/10-mkmm-tmpfs-pre.hook /usr/share/mkmm/10-mkmm-tmpfs-pre.hook


AddPackage refind-git # rEFInd Boot Manager - git version (Aetf fixed)
CopyFile /usr/local/bin/refind-upgrade 755
CopyFile /etc/pacman.d/hooks/refind.hook

