MatchHost || return 0

# This host serves as the homelab server in house, joining the k8s cluster as a worker.
# As such, it has the minimal amount of packages.

# We start from the basic Archlinux install following
# https://wiki.archlinux.org/title/Installation_guide#Localization
# Specifically, we assume a system state:
#   * partitions and filesystems are created using systemd-gpt-auto-generator compatible types
#     + no need to create /etc/fstab
#   * `base` package installed
#     + `git`, `openssh`, `sudo`, `neovim`
#   * timezone (`/etc/localtime`) and time adjusted (`/etc/adjtime`)
#   * user account created with uid/gid 1000
#     + user has sudo access
#       - `sudo` installed
#       - `wheel` group configured in sudoers
#       - user belongs to `wheel` group

# Base system installation
#   * create partitions & filesystems
#   * mount to /mnt, /mnt/efi
#   * pacstrap /mnt base git openssh sudo neovim
#   * arch-chroot /mnt
#   * echo "Hostname" > /etc/hostname
#   * ln -sf /usr/share/zoneinfo/America/Los_Angles /etc/localtime
#   * hwclock --systohc
#   * echo "%wheel ALL=ALL (ALL)" /etc/sudoers.d/wheel
#   * useradd -m -U -G wheel aetf
#   * passwd aetf
#   * su aetf
#   * curl -JOL .... yadm
#   * yadm clone https://github.com/Aetf/dotfiles
#   * cd /tmp && git clone https://CyberShadow/aconfmgr
#   * cd aconfmgr && ./aconfmgr -c ~/.config/aconfmgr apply

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
## MANUAL: install bootloader to disk `bootctl install`

# The bootloader loads unified kernel image (UKI)
AddRole initramfs-dracut
CreateLink /etc/pixmaps/oemlogo.bmp /usr/share/systemd/bootctl/splash-arch.bmp
CopyFile /etc/dracut.conf.d/unused-modules.conf

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

## The server will also join zerotier-one network
AddRole zerotier

# The last step of a usable server is ssh
AddRole ssh

# Now the system boots, we configure the user space

# First install packages to be able to compile packages
AddRole packaging

# Then many familiar cli tools
AddRole rich-cli

# Rust is a must on any system, especially for rust-scripts
#AddRole rust-dev

# Rest of the machine will be managed by k8s
AddRole k8s
