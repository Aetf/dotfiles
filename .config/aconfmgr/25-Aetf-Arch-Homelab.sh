MatchHost || return 0

# This host serves as the homelab server in house, joining the k8s cluster as a worker.
# As such, it has the minimal amount of packages.

# We first make sure bootstrapping is completed

# First ack the base installation.
AddRole base

# For filesystem layout, we rely on systemd-gpt-auto-generator, so make sure /etc/fstab is clean.
GetPackageOriginalFile filesystem /etc/fstab >/dev/null
# Rest of the configs asumes ESP mounted at /efi, so let's create that directory.
# From systemd doc:
# > Mount and automount units for the EFI System Partition (ESP) are generated on EFI systems.
# > The ESP is mounted to /boot/ (except if an Extended Boot Loader partition exists, see below),
# > unless a mount point directory /efi/ exists, in which case it is mounted there. Since this
# > generator creates an automount unit, the mount will only be activated on-demand, when accessed.
# > On systems where /boot/ (or /efi/ if it exists) is an explicitly configured mount (for example,
# > listed in fstab(5)) or where the /boot/ (or /efi/) mount point is non-empty, no mount units are
# > generated.
CreateDir /efi
# TODO: check the automount timeout option

# Now we config following the bootup sequence.
# To boot the system, we use systemd-boot which is simple enough for server usage.
# MANUAL: install bootloader to disk `bootctl install`

# We use stock Archlinux kernel with intel ucode upgrades
AddPackage linux
AddPackage intel-ucode

# The bootloader loads unified kernel image (UKI)
AddRole initramfs-dracut
CreateLink /etc/pixmaps/oemlogo.bmp /usr/share/systemd/bootctl/splash-arch.bmp
CopyFile /etc/dracut.conf.d/unused-modules.conf
## Load nvme kernel module even we don't install nvme-cli package
CopyFile /etc/dracut.conf.d/nvme.conf
## dracut will automatically add btrfs kernel module when the cli is present in
## system
AddPackage btrfs-progs # Btrfs filesystem utilities

# After the kernel boots up, we need network,
echo "Aetf-Arch-Homelab" > "$(CreateFile /etc/hostname)"

## For wireless connection, iwd is used
## MANUAL: connect and save wifi password
AddPackage iwd

## Then systemd-networkd and systemd-resolvd are used to manage the interfaces.
AddRole network-systemd
## We setup DHCP on both Ethernet and WiFi network interfaces.
CopyFile /etc/systemd/network/20-wired.network
CopyFile /etc/systemd/network/25-wireless.network

# The last thing is to setup pacman and install packages for AUR
AddRole packaging

# Now the system boots, we stop here and leave further complex setups after reboot
## MANUAL: remember to run locale-gen
IsBootstrap && return 0

# Further networking configurations

# The server will join the zerotier-one network
AddRole zerotier

# And reachable via ssh
AddRole ssh

# Additional userspace configurations

# Many familiar cli tools
AddRole rich-cli

# Rust is a must on any system, especially for rust-scripts
AddRole rust-dev

# Rest of the machine will be managed by k8s
AddRole k8s
