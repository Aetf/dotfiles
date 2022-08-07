CopyFile /usr/local/bin/mount-esp 755

AddPackage dracut
AddOptionalPackage dracut \
    pigz 'faster gzip compression' `# Parallel implementation of the gzip file compressor`
CopyFile /etc/pacman.d/hooks/60-dracut-remove-uki.hook
CopyFile /etc/pacman.d/hooks/90-dracut-install-uki.hook
CopyFile /usr/local/bin/dracut-install-uki 755
CopyFile /usr/local/bin/dracut-remove-uki 755
CopyFile /etc/dracut.conf.d/defaults.conf
CopyFile /etc/dracut.conf.d/uefi.conf

# Each file in these directory adds additional files to the uki
# The file format is one path per line, empty lines and those starting with `#` are ignored.
CreateDir /etc/dracut.conf.d/install.d/normal
CreateDir /etc/dracut.conf.d/install.d/fallback

# Each file in these directory adds kernel command line that go into the final UKI
CopyFile /etc/kernel/cmdline.d/README

# Save current running kernel's modules
AddPackage mkmm # Moviuro's Kernel Module Manager
CreateLink /etc/pacman.d/hooks/10-mkmm-tmpfs-post.hook /usr/share/mkmm/10-mkmm-tmpfs-post.hook
CreateLink /etc/pacman.d/hooks/10-mkmm-tmpfs-pre.hook /usr/share/mkmm/10-mkmm-tmpfs-pre.hook
SystemdEnable mkmm /usr/lib/systemd/system/mkmm-bleach.service
