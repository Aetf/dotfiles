# Enable multilib
CopyFile /etc/pacman.d/confs/repos.conf

# For steam, which will be installed via flatpak
AddPackage $FOREIGN game-devices-udev # Udev rules for controllers

# Emulators
AddPackage dosbox # Emulator with builtin DOS for running DOS Games
AddPackage chiaki-git # Unofficial PlayStation 4 remote play client
#AddPackage citra-qt-git # An experimental open-source Nintendo 3DS emulator/debugger
