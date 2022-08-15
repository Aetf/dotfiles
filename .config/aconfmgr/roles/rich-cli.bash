AddPackage --foreign kmscon-patched-git # Terminal emulator based on Kernel Mode Setting (KMS) (forked and patched version)
CopyFile /etc/kmscon/kmscon.conf
# defer because it's hard to build kmscon now
# SystemdEnable --name kmsconvt@tty1.service kmscon-patched-git /usr/lib/systemd/system/kmsconvt@.service
CreateLink /etc/systemd/system/autovt@.service /usr/lib/systemd/system/kmsconvt@.service

# This will read ~/.config/user-tmpfiles.d/* to create directories
SystemdEnable --type user systemd /usr/lib/systemd/user/systemd-tmpfiles-setup.service

# Useful fonts
AddRole font

AddPackage man-db # A utility for reading man pages
AddPackage man-pages # Linux man pages

# This will be handled in k8s as a service that runs on multiple machines
# AddPackage syncthing # Open Source Continuous Replication / Cluster Synchronization Thing

AddPackage traceroute # Tracks the route taken by packets over an IP network
AddPackage nmap # Utility for network discovery and security auditing
AddPackage lshw # A small tool to provide detailed information on the hardware configuration of the machine.
AddPackage gnu-netcat # GNU rewrite of netcat, the network piping application
AddPackage aria2 # Download utility that supports HTTP(S), FTP, BitTorrent, and Metalink
AddPackage cpupower # Linux kernel tool to examine and tune power saving related features of your processor
AddPackage hexyl # Colored command-line hex viewer
AddPackage ps_mem # List processes by memory usage
AddPackage htop # Interactive process viewer
AddPackage powertop # A tool to diagnose issues with power consumption and power management
AddPackage iotop # View I/O usage of processes
AddPackage iperf3 # TCP, UDP, and SCTP network bandwidth measurement tool

AddPackage --foreign rnr # A CLI tool to rename files and directories that supports regex.
AddPackage mtr # Combines the functionality of traceroute and ping into one tool (CLI version)
AddPackage dua-cli # A tool to conveniently learn about the disk usage of directories, fast!

# Use polkit to provide some alternative to sudo, used by neovim
AddPackage polkit
