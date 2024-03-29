IgnorePath '/.swapfiles'
IgnorePath '/.snapshots'
IgnorePath '/**/UNMOUNTED'
IgnorePath '*/lost+found/*'

# Ignore subdirectories in /efi separately so that /efi itself is kept
IgnorePath '/efi/EFI/*'
IgnorePath '/efi/loader/*'

IgnorePath '/var/*'
IgnorePath '/opt/*'
IgnorePath '/usr/lib*/*'
IgnorePath '/usr/share/applications/*'
IgnorePath '/usr/share/mime/*'
IgnorePath '/usr/share/fonts/*'
IgnorePath '/usr/share/icons/*'
IgnorePath '/usr/share/glib-2.0/*'
IgnorePath '/usr/share/info/dir'
IgnorePath '/usr/share/perl5/*'
IgnorePath '/usr/share/waydroid-extra/*'
IgnorePath '/usr/share/.mono/*'

IgnorePath '/boot/efi_backup/*'

# Host specific
IgnorePath '/etc/adjtime'
IgnorePath '/etc/crypttab'
IgnorePath '/etc/hostname'
IgnorePath '/etc/localtime'
IgnorePath '/etc/passwd'
IgnorePath '/etc/shadow'
IgnorePath '/etc/group'
IgnorePath '/etc/gshadow'
IgnorePath '/etc/machine-id'
IgnorePath '/etc/shells'
IgnorePath '/etc/luks-keys/*'
IgnorePath '/etc/ssh/*_key*'
IgnorePath '/etc/lvm/*'
IgnorePath '/etc/os-release'
IgnorePath '/etc/rancher/node/*'

IgnorePath '/etc/ssl/*'
IgnorePath '/etc/ca-certificates/*'

IgnorePath '/etc/.*'
IgnorePath '/etc/*-'
IgnorePath '/etc/*.cache'

IgnorePath '/etc/cni/*'
IgnorePath '/etc/NetworkManager/system-connections/*'

IgnorePath '/etc/docker/key.json'
IgnorePath '/etc/pacman.d/gnupg/*'
IgnorePath '/etc/pacman.d/mirrorlist'
IgnorePath '/etc/texmf/*'
IgnorePath '/etc/xml/*'
IgnorePath '/etc/multipath/*'
IgnorePath '/etc/xdg/nvim/.netrwhist'
IgnorePath '/etc/fwupd/remotes.d/*'

IgnorePath '/etc/cups/*'
IgnorePath '/etc/printcap'

IgnorePath '/etc/audit/audit.rules'

# systemd-creds, see https://systemd.io/CREDENTIALS/
IgnorePath '/etc/credstore'
IgnorePath '/etc/credstore.encrypted'
