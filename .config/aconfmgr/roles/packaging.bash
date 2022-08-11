# Generate mirrorlist
AddPackage reflector # A Python 3 module and script to retrieve and filter the latest Pacman mirror list.

# Make pacman read configs from the directory
CreateFile /etc/pacman.d/confs/empty.conf >/dev/null
cat >>"$(GetPackageOriginalFile pacman /etc/pacman.conf)" <<EOF
# BEGIN aconfmgr MANAGED BLOCK
[options]
# Explicitly set the default value, so later in *.conf the list can be appended
CacheDir    = /var/cache/pacman/pkg/
# Custom options
Include = /etc/pacman.d/confs/*.conf
# END aconfmgr MANAGED BLOCK
EOF

## Mute db signature warnings
CopyFile /etc/pacman.d/confs/no-db-sig.conf

## Enable parallel download
CopyFile /etc/pacman.d/confs/parallel.conf

## Fancy eye candy
CopyFile /etc/pacman.d/confs/fancy.conf

## Make sure we can compile packages
AddPackageGroup base-devel
AddPackage mold # A Modern Linker

# AUR packages
## Configs for compiling packages
f="$(GetPackageOriginalFile pacman /etc/makepkg.conf)"
## Higher parallelism
sed -i -E 's/^#?MAKEFLAGS=.+$/MAKEFLAGS="-j$(nproc)"/g' "$f"
## In-memory build dir
sed -i -E 's|^#?BUILDDIR=.+$|BUILDDIR=/tmp/makepkg|g' "$f"
## Set packager
sed -i -E 's/^#?PACKAGER=.+$/PACKAGER="Aetf <aetf@unlimited-code.works>"/g' "$f"

# Helpful tools for package dev
AddPackage pacman-contrib # Contributed scripts and tools for pacman systems
AddPackage devtools # Tools for Arch Linux package maintainers
AddPackage debuginfod # Handle ELF object files and DWARF debugging information (debuginfod)
AddPackage --foreign downgrade # Bash script for downgrading one or more packages to a version in your cache or the A.L.A.
AddPackage namcap # A Pacman package analyzer

## AUR helper
AddPackage --foreign paru-bin # Feature packed AUR helper
AddOptionalPackage paru-bin \
    asp "downloading repo pkgbuilds" `# Arch Linux build source file management tool`
cat > "$(CreateFile /etc/paru.conf)" <<'EOF'
#
# $PARU_CONF
# /etc/paru.conf
# ~/.config/paru/paru.conf
#
# See the paru.conf(5) manpage for options

#
# GENERAL OPTIONS
#
[options]
PgpFetch
Devel
Provides
DevelSuffixes = -git -cvs -svn -bzr -darcs -always -hg -fossil

#
# Binary OPTIONS
#
#[bin]
#FileManager = vifm
#MFlags = --skippgpcheck
#Sudo = doas

# Custom options
[options]
BottomUp
RemoveMake
SudoLoop
CombinedUpgrade
CleanAfter
UpgradeMenu
NewsOnUpgrade
Chroot
LocalRepo
EOF
### local AUR repo (also needs config in paru)
CopyFile /etc/pacman.d/confs/local-aur.conf

