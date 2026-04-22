# For hosts with direct USB access
AddPackage pcsclite
SystemdEnable pcsclite /usr/lib/systemd/system/pcscd.socket

# Make GnuPG use pcscd
AddPackage gnupg

