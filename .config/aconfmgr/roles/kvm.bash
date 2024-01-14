# Headless full-system emulation for x86_64 only
AddPackage qemu-base
AddOptionalPackage qemu-base \
    qemu-hw-usb-host 'for host USB support' \
    qemu-hw-usb-redirect 'for USB redirect support'
AddPackage swtpm # Libtpms-based TPM emulator with socket, character device, and Linux CUSE interface
AddPackage edk2-ovmf # Firmware for Virtual Machines (x86_64, i686)
AddPackage libvirt # API for controlling virtualization engines (openvz,kvm,qemu,virtualbox,xen,etc)
SystemdEnable libvirt /usr/lib/systemd/system/libvirtd.service
SystemdEnable libvirt /usr/lib/systemd/system/virtlogd.socket
SystemdEnable libvirt /usr/lib/systemd/system/virtlockd.socket
SystemdEnable libvirt /usr/lib/systemd/system/libvirtd.socket
SystemdEnable libvirt /usr/lib/systemd/system/libvirtd-ro.socket
## These are auto created
IgnorePath '/etc/libvirt/nwfilter/*'
IgnorePath '/etc/libvirt/storage/*'

# Make sure our user belongs to the kvm group
cat > "$(CreateFile /etc/sysusers.d/kvm-user.conf)" <<EOF
m aetf kvm
EOF

# Create an iso directory for ISOs that the system qemu can access
# Note the write and sticky bit in group, so files created in this directory can
# automatically be accessible to the kvm group.
CreateDir /isos 2775 "qemu" "kvm"
cat >> "$(CreateFile /isos/README.md '' 'qemu' 'kvm')" << 'EOF'
# ISOs for System Virtual Machines
This directory is owned by the `kvm` group and is group writable with the sticky
bit set. If the user belongs to the `kvm` group, simply put files in this
directory and it will be accessible by bare qemu and/or libvirt qemu.
EOF
IgnorePath /isos/*.iso

# Configure libvirt to use kvm group to launch qemu and don't mess with iso
# permissions
cat >> "$(GetPackageOriginalFile libvirt /etc/libvirt/qemu.conf)" <<EOF
# -- Managed by aconfmgr
# Match the bare qemu setup to run as the kvm group so it can access /isos
group = "kvm"
# -- End managed by aconfmgr
EOF

# Silence split lock detection warnings
# See https://lwn.net/Articles/816918/
cat > "$(CreateFile /etc/kernel/cmdline.d/kvm-split-lock.conf)" <<EOF
split_lock_detect=off
EOF
