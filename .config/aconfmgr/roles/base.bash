AddPackage base
AddPackage pacman-contrib # Contributed scripts and tools for pacman systems
AddPackage rng-tools # Random number generator related utilities

AddPackageGroup base-devel
AddPackage mold # A Modern Linker

AddPackage zsh # A very advanced and programmable command interpreter (shell) for UNIX
AddPackage devtools # Tools for Arch Linux package maintainers
AddPackage debuginfod # Handle ELF object files and DWARF debugging information (debuginfod)

AddPackage zip # Compressor/archiver for creating and modifying zipfiles
AddPackage lzip # A lossless file compressor based on the LZMA algorithm
AddPackage gzip # GNU compression utility

AddPackage git # the fast distributed version control system
AddPackage git-filter-repo # Quickly rewrite git repository history (filter-branch replacement)
AddPackage git-lfs # Git extension for versioning large files

AddPackage neovim # Fork of Vim aiming to improve user experience, plugins, and GUIs
AddPackage neovim-symlinks # Runs neovim if vi or vim is called

AddPackage rsync # A fast and versatile file copying tool for remote and local files
AddPackage tmux # A terminal multiplexer

AddPackage aconfmgr-git # A configuration manager for Arch Linux

CopyFile /etc/sudoers.d/00-basic
CopyFile /etc/locale.conf
CreateFile /etc/vconsole.conf > /dev/null
