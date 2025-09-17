# Login
CopyFile /etc/sddm.conf.d/hidpi.conf
CopyFile /etc/sddm.conf.d/kde_settings.conf
IgnorePath '/usr/share/sddm/themes/*'

# Plasma DE
AddPackage plasma-meta # Meta package to install KDE Plasma
AddOptionalPackage plasma-meta \
    plasma-sdk 'Development tools' `# Applications useful for Plasma development` \
    flatpak-kcm 'Manage Flatpak applications from systemsettings' `# Flatpak Permissions Management KCM` \
    plymouth-kcm 'Configure Plymouth from systemsettings' `# KCM to manage the Plymouth (Boot) theme`

AddOptionalPackage plasma-workspace \
    appmenu-gtk-module 'global menu support for GTK2 and some GTK3 applications' `# Application Menu GTK+ Module` \
    kwayland-integration 'Wayland integration for Qt5 applications' `# Provides integration plugins for various KDE frameworks for the wayland windowing system`
AddPackage plasma-systemmonitor # An interface for monitoring system sensors, process information and other system resources
AddPackage colord-kde # Interfaces and session daemon to colord for KDE
AddPackage xdg-desktop-portal # Desktop integration portals for sandboxed apps
AddPackage kio-gdrive # KIO Slave to access Google Drive
AddOptionalPackage kio \
    kdoctools5 "for the help kioslave" `# Documentation generation from docbook`
AddOptionalPackage kio-extras \
    kimageformats5 "thumbnails for additional image formats" `# Image format plugins for Qt5` \
    qt5-imageformats 'thumbnails for additional image formats' `# Plugins for additional image formats: TIFF, MNG, TGA, WBMP`
AddOptionalPackage kde-gtk-config \
    xsettingsd 'apply settings to GTK applications on the fly' `# Provides settings to X11 applications via the XSETTINGS specification`

# This will ensure ~/downloads, ~/documents etc.
SystemdEnable --type user xdg-user-dirs /usr/lib/systemd/user/xdg-user-dirs-update.service


AddPackage flatpak # Linux application sandboxing and distribution framework (formerly xdg-app)

# Theme
#AddPackage latte-dock-git # Latte is a dock based on plasma frameworks that provides an elegant and intuitive experience for your tasks and plasmoids
AddPackage kvantum-theme-arc # Arc theme for Kvantum
AddPackage papirus-icon-theme # Papirus icon theme
AddPackage arc-gtk-theme # A flat theme with transparent elements for GTK 2,3,4 and Gnome-Shell

AddPackage syncthingtray-qt6 # Tray application for Syncthing
AddPackage plasma6-applets-window-title
AddPackage plasma-applet-window-buttons

# CLI utils
AddPackage neovide # No Nonsense Neovim Client in Rust
AddPackage wl-clipboard # Command-line copy/paste utilities for Wayland
AddPackage handlr-regex # Powerful alternative to xdg-utils written in Rust
AddPackage rclone
CopyFile /etc/sudoers.d/00-gui

# A/V
AddPackage pipewire # Low-latency audio/video router and processor
AddPackage pipewire-alsa # Low-latency audio/video router and processor - ALSA configuration
AddPackage pipewire-jack # Low-latency audio/video router and processor - JACK support
AddPackage pipewire-pulse # Low-latency audio/video router and processor - PulseAudio replacement
AddPackage wireplumber # Session / policy manager implementation for PipeWire
# Enable wireplumber by default for all users
SystemdEnable --type user pipewire /usr/lib/systemd/user/pipewire.socket
SystemdEnable --type user pipewire-pulse /usr/lib/systemd/user/pipewire-pulse.socket
SystemdEnable --type user wireplumber /usr/lib/systemd/user/wireplumber.service

AddPackage alsa-utils # Advanced Linux Sound Architecture - Utilities
AddPackage pavucontrol-qt # A Pulseaudio mixer in Qt (port of pavucontrol)
AddPackage qjackctl # A Qt front-end for the JACK low-latency audio server
AddOptionalPackage qjackctl \
    qt6-wayland 'for native wayland support' `# Provides APIs for Wayland`
AddPackage qpwgraph # PipeWire Graph Qt GUI Interface

# Devices
AddPackage piper # GTK application to configure gaming mice
AddPackage yubikey-manager-qt # Cross-platform application for configuring any YubiKey over all USB transports
SystemdEnable pcsclite /usr/lib/systemd/system/pcscd.socket

AddPackage cups
AddPackage print-manager # A tool for managing print jobs and printers
AddPackage system-config-printer # A CUPS printer configuration tool and status applet
AddOptionalPackage system-config-printer \
    cups-pk-helper "PolicyKit helper to configure cups with fine-grained privileges" `# A helper that makes system-config-printer use PolicyKit`\
    python-pysmbc 'SMB browser support' `# Python 3 bindings for libsmbclient`
SystemdEnable cups /usr/lib/systemd/system/cups.socket

AddPackage sane-airscan # SANE - SANE backend for AirScan (eSCL) and WSD document scanners
CopyFile /etc/sane.d/dll.conf
CopyFile /etc/sane.d/net.conf

# Terminal Emulator
AddPackage yakuake # A drop-down terminal emulator based on KDE konsole technology
AddPackage yakuake-skin-breeze-thin-dark # A Breeze Thin Dark skin for Yakuake (Plasma 5)
AddPackage alacritty # A cross-platform, GPU-accelerated terminal emulator
AddPackage konsole # KDE terminal emulator

# Apps
AddPackage ark # Archiving Tool
AddOptionalPackage ark \
    7zip '7Z format support' `# File archiver for extremely high compression` \
    unarchiver 'RAR format support' `# RAR format support`
AddPackage dolphin # KDE File Manager
AddOptionalPackage dolphin \
    ffmpegthumbs "video thumbnails" `# FFmpeg-based thumbnail creator for video files` \
    kdegraphics-thumbnailers "PDF and PS thumbnails" `# Thumbnailers for various graphics file formats`
AddPackage filelight # View disk usage information
AddPackage font-manager # A simple font management application for GTK+ Desktop Environments
AddPackage fontforge # Outline and bitmap font editor

AddPackage kate # Advanced Text Editor
AddOptionalPackage kate \
    markdownpart 'markdown preview' `# KPart for rendering Markdown content` \
    svgpart 'svg preview' `# A KPart for viewing SVGs`

AddPackage kdeconnect # Adds communication between KDE and your smartphone
AddOptionalPackage kdeconnect \
    sshfs "remote filesystem browser" `# FUSE client based on the SSH File Transfer Protocol`
AddPackage kdialog # A utility for displaying dialog boxes from shell scripts
AddPackage kdiff3 # A file comparator/merge tool
AddPackage kolourpaint # Paint Program
AddPackage keepassxc # Cross-platform community-driven port of Keepass password manager
AddPackage kgpg # A GnuPG frontend
AddPackage krdc # Remote Desktop Client
AddOptionalPackage krdc \
    freerdp "RDP support" `# Free implementation of the Remote Desktop Protocol (RDP)`
AddPackage kruler # Screen Ruler
AddPackage ksystemlog # System log viewer tool
AddPackage picard # Official MusicBrainz tagger
AddPackage qbittorrent # An advanced BitTorrent client programmed in C++, based on Qt toolkit and libtorrent-rasterbar

AddPackage partitionmanager # A KDE utility that allows you to manage disks, partitions, and file systems
AddOptionalPackage kpmcore \
    fatresize 'FAT resize support' `# A utility to resize FAT filesystems using libparted` \
    exfatprogs 'exFAT support' `# exFAT filesystem userspace utilities for the Linux Kernel exfat driver`

AddPackage elisa # A simple music player aiming to provide a nice experience for its users
AddPackage haruna

AddPackage gwenview # A fast and easy to use image viewer
AddPackage qview # qView is a Qt image viewer designed with minimalism and usability in mind.

AddPackage libreoffice-fresh # office

AddPackage simplescreenrecorder # A feature-rich screen recorder that supports X11 and OpenGL.
AddPackage spectacle # KDE screenshot capture utility
AddPackage sqlitebrowser # SQLite Database browser is a light GUI editor for SQLite databases, built on top of Qt
AddPackage wireshark-qt # Network traffic and protocol analyzer/sniffer - Qt GUI

AddPackage kgraphviewer # A Graphviz dot graph file viewer for KDE
AddPackage masterpdfeditor-free # A complete solution for creation and editing PDF files - Free version without watermark
AddPackage okular # Document Viewer
AddPackage zathura # Minimalistic document viewer
AddOptionalPackage zathura \
    zathura-pdf-poppler 'PDF support using Poppler' `# Adds pdf support to zathura by using the poppler engine`
AddOptionalPackage poppler \
    poppler-data 'highly recommended encoding data to display PDF documents with certain encodings and characters' `# Encoding data for the poppler PDF rendering library`

AddPackage zotero-bin # Zotero Standalone. Is a free, easy-to-use tool to help you collect, organize, cite, and share your research sources.
AddPackage obsidian # A powerful knowledge base that works on top of a local folder of plain text Markdown files

AddPackage yubikey-personalization-gui

# Browser
AddPackage vivaldi # An advanced browser made with the power user in mind.
AddOptionalPackage vivaldi \
    vivaldi-ffmpeg-codecs  'playback of proprietary video/audio' `# additional support for proprietary codecs for vivaldi`
AddPackage firefox # Standalone web browser from mozilla.org

# Comm
AddPackage discord # All-in-one voice and text chat for gamers that's free and secure.
AddPackage element-desktop # Glossy Matrix collaboration client — desktop version.

AddPackage akvcam-dkms # Virtual camera for Linux
CopyFile /etc/akvcam/config.ini
CopyFile /etc/akvcam/default_frame.bmp
CopyFile /etc/modules-load.d/akvcam.conf

AddRole ntfs
