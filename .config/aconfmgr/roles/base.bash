# Ack the base installation
AddPackage base

# Enable ntp time sync
SystemdEnable systemd /usr/lib/systemd/system/systemd-timesyncd.service

# For basic localization, we'll enable both en and ch, but en_US.UTF8 will be the default
cat >> "$(GetPackageOriginalFile glibc /etc/locale.gen)" <<EOF
C.UTF-8 UTF-8
en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8
zh_CN.GB18030 GB18030
EOF
echo "LANG=en_US.UTF-8" > "$(CreateFile /etc/locale.conf)"

# Make sure users in wheel group can sudo
CopyFile /etc/sudoers.d/00-basic

# Basic system
AddPackage zsh # A very advanced and programmable command interpreter (shell) for UNIX

## We slightly abuse systemd-sysusers to create our human user as we only want a
## simple local user anyway.
cat > "$(CreateFile /etc/sysusers.d/aetf.conf)" <<EOF
# Slightly abuse systemd-sysusers to create our human user as we simply want a
# local user anyway.
u aetf 1000:1000 "The one and only human operator" /home/aetf /usr/bin/zsh
m aetf users
# We are the wheel!
m aetf wheel
EOF
## MANUAL: make sure to create the home dir
#CreateDir /home/aetf "750" "aetf" "users"

AddPackage unrar # The RAR uncompression program
AddPackage unzip # For extracting and viewing files in .zip archives
AddPackage zip # Compressor/archiver for creating and modifying zipfiles
AddPackage lzip # A lossless file compressor based on the LZMA algorithm
AddPackage gzip # GNU compression utility

AddPackage git # the fast distributed version control system
AddPackage git-filter-repo # Quickly rewrite git repository history (filter-branch replacement)
AddPackage git-lfs # Git extension for versioning large files

AddPackage neovim # Fork of Vim aiming to improve user experience, plugins, and GUIs
AddPackage $FOREIGN neovim-symlinks # Runs neovim if vi or vim is called

AddPackage rsync # A fast and versatile file copying tool for remote and local files
AddPackage tmux # A terminal multiplexer

AddPackage $FOREIGN aconfmgr-git # A configuration manager for Arch Linux

# Some system fixes
## We used to need rng-tools during startup to make sure /dev/random nonblocking,
## but that's not necessary since linux 5.6
## See: https://github.com/torvalds/linux/commit/30c08efec8884fb106b8e57094baa51bb4c44e32

## Pacman already runs ldconfig after updating/installing packages, so
## this is useless and just slows down the boot.
SystemdMask ldconfig.service

## Without auditd running, kernel audit events will flood the kmsg
## See: https://github.com/systemd/systemd/issues/15324#issuecomment-610327560
SystemdEnable audit /usr/lib/systemd/system/auditd.service
