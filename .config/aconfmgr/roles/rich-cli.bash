AddPackage kmscon-patched-git # Terminal emulator based on Kernel Mode Setting (KMS) (forked and patched version)
CopyFile /etc/kmscon/kmscon.conf
CreateLink /etc/systemd/system/autovt@.service /usr/lib/systemd/system/kmsconvt@.service

AddPackage man-db # A utility for reading man pages
AddPackage man-pages # Linux man pages

AddPackage zerotier-one # Creates virtual Ethernet networks of almost unlimited size.
CopyFile /etc/systemd/system/zerotier-one.service
AddPackage syncthing # Open Source Continuous Replication / Cluster Synchronization Thing

AddPackage traceroute # Tracks the route taken by packets over an IP network
AddPackage nmap # Utility for network discovery and security auditing
AddPackage lshw # A small tool to provide detailed information on the hardware configuration of the machine.
AddPackage gnu-netcat # GNU rewrite of netcat, the network piping application
AddPackage aria2 # Download utility that supports HTTP(S), FTP, BitTorrent, and Metalink
AddPackage atool # A script for managing file archives of various types
AddPackage cpupower # Linux kernel tool to examine and tune power saving related features of your processor
AddPackage hexyl # Colored command-line hex viewer
AddPackage inotify-tools # inotify-tools is a C library and a set of command-line programs for Linux providing a simple interface to inotify.
AddPackage ps_mem # List processes by memory usage
AddPackage htop # Interactive process viewer
AddPackage powertop # A tool to diagnose issues with power consumption and power management
AddPackage iotop # View I/O usage of processes
AddPackage iperf3 # TCP, UDP, and SCTP network bandwidth measurement tool

AddPackage rnr # A CLI tool to rename files and directories that supports regex.
AddPackage mtr # Combines the functionality of traceroute and ping into one tool (CLI version)
AddPackage handlr-bin # Powerful alternative to xdg-utils written in Rust
AddPackage dua-cli # A tool to conveniently learn about the disk usage of directories, fast!

AddPackage ventoy-bin # A new multiboot USB solution
AddPackage github-cli # The GitHub CLI
AddPackage dnscontrol-bin # Synchronize your DNS to multiple providers from a simple DSL (binary release)
AddPackage hexo-cli # Command line interface for Hexo
AddPackage pulumi # Modern Infrastructure as Code
AddPackage kubectl # A command line tool for communicating with a Kubernetes API server
AddPackage kubeseal # A Kubernetes controller and tool for one-way encrypted Secrets
AddPackage pamtester # Tiny program to test the pluggable authentication modules (PAM) facility
CopyFile /etc/pam.d/testpam
