CopyFile /etc/makepkg.conf
CopyFile /etc/pacman.conf
CopyFile /etc/pacman.d/confs/fancy.conf
CopyFile /etc/pacman.d/confs/local-aur.conf
CopyFile /etc/pacman.d/confs/no-db-sig.conf
CopyFile /etc/pacman.d/confs/no-nvidia-vulkan.conf
CopyFile /etc/pacman.d/confs/no-syslinux.conf
CopyFile /etc/pacman.d/confs/parallel.conf
CopyFile /etc/pacman.d/confs/repos.conf

AddPackage reflector # A Python 3 module and script to retrieve and filter the latest Pacman mirror list.


AddPackage downgrade # Bash script for downgrading one or more packages to a version in your cache or the A.L.A.
AddPackage namcap # A Pacman package analyzer

AddPackage paru # Feature packed AUR helper
AddOptionalPackage paru \
    asp "downloading repo pkgbuilds" `# Arch Linux build source file management tool`
CopyFile /etc/paru.conf

AddPackage pacvis-git # Visualize pacman local database using Vis.js, inspired by pacgraph

CopyFile /etc/sudoers.d/50-aur_builder-pacman
