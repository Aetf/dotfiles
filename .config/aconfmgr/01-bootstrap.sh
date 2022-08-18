# Bootstrap runs in the initial installation chroot, to minimally setup the
# system such that it can be booted into for further setup. Bootstrapping is
# different for each machine, while this file will provide some common
# facilities.
#
# After bootstrapping, the system should be bootable with user account
# configured. Specifically, we aim to bring the system from the barebone state
# after following the Archlinux installation guide[1]:
#
#   * partition & filesystem configured (either /etc/fstab or
#   systemd-gpt-auto-generator compatible)
#     + encrypted volumes configured
#   * `base` package installed
#   * timezone (`/etc/localtime`) and time adjusted (`/etc/adjtime`)
#   * mirrorlist created via reflector
#   * user account created with uid/gid 1000
#   * we currently run in chroot as root
#
# to the bootstrapped state:
#
#   * additional essential package installed
#     + `git`, `curl`, `neovim`
#   * user has sudo access
#     + `sudo` installed
#     + `wheel` group configured in sudoers
#     + user belongs to the `wheel` group
#   * AUR helper is installed
#     + only AUR packages with simple dependencies shall be installed in this
#     stage, as the builtin AUR package handler has limited functionality
#     + AUR local repo configured
#
# [1]: https://wiki.archlinux.org/title/Installation_guide#Localization

# Base system installation
#   * create partitions & filesystems
#   * mount to /mnt, /mnt/efi
#   * pacstrap /mnt base git openssh sudo neovim
#   * arch-chroot /mnt
#   * echo "Hostname" > /etc/hostname
#   * ln -sf /usr/share/zoneinfo/America/Los_Angles /etc/localtime
#   * hwclock --systohc
#   * echo "%wheel ALL=ALL (ALL)" /etc/sudoers.d/wheel
#   * reflector --country="United States" --verbose --latest 50 --fastest 5
#       --age 1 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
#   * useradd -m -U -G wheel aetf
#   * passwd aetf
#   * su aetf
#   * curl -JOL .... yadm
#   * yadm clone https://github.com/Aetf/dotfiles
#   * cd /tmp && git clone https://CyberShadow/aconfmgr
#   * cd aconfmgr && ./aconfmgr -c ~/.config/aconfmgr apply


#
# Check if this machine is in the bootstrapping stage
#
function IsBootstrap() {
    [[ ! -f /.bootstrapped ]]
}


# Always create the stamp in config
CreateFile /.bootstrapped >/dev/null

# Since packages in AUR local repo is not considered foreign, we need to change
# the desired config depending on whether we are in bootstrap or not
if IsBootstrap; then
    FOREIGN="--foreign"
else
    FOREIGN=""
fi
