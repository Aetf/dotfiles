# Homelab specific kvm settings, pulled out to separated file due to complexity

## We don't want the default NAT network, and we don't install dependencies for
## it anyway. Tell pacman to not extract it
cat >$(CreateFile /etc/pacman.d/confs/no-libvirt-default-net.conf) <<EOF
# No libvirt default NAT network as we don't install its dependencies anyway.
[options]
NoExtract = etc/libvirt/qemu/networks/default.xml
EOF

## Prevent some kernel driver from loading
cat >$(CreateFile /etc/modprobe.d/kvm-blacklist.conf) <<EOF
# even though vfio-pci should be loaded first so nouveau doesn't have a chance
# to take the GPU, block it to reduce some resource usage
blacklist nouveau
# the bluetooth device will be passed in as USB device, preventing loading the
# kernel bt driver to avoid it messing with the device at all
blacklist btusb bluetooth
EOF

# Isolate passthrough devices

## NVIDIA GTX 3090 [10de:2204]
## NVIDIA GTX 3090 audio controller [10de:1aef]
## Samsung NVME SSD EVO 970 Pro [144d:a808]
## Startech PCIE USB 3.0 card [1b21:3042]
##     (connecting the monitor USB hub, which has mouse and keybaord)
cat >$(CreateFile /etc/modprobe.d/kvm-vfio.conf) <<EOF
options vfio-pci ids=10de:2204,10de:1aef,144d:a808,1b21:3042
EOF

# Load vfio driver early
cat >$(CreateFile /etc/dracut.conf.d/kvm-vfio.conf) <<EOF
force_drivers+=" vfio_pci vfio vfio_iommu_type1 vfio_virqfd "
EOF

# Isolate CPU cores and use kernel command line to remove them from the general
# kernel SMP balancing and scheduler algorithms. The only way to move a process
# onto or of an "isolated" CPU is via the CPU affinity sysscalls. This is the
# preferred way to isolate CPUs
cat >$(CreateFile /etc/kernel/cmdline.d/vm-cpus.conf) <<EOF
isolcpus=0,1,2,3,4,5,6,7,8,9,10,11
EOF

# Create static 1GiB hugepages
cat >$(CreateFile /etc/kernel/cmdline.d/hugepages.conf) <<EOF
hugepages=16 default_hugepagesz=1G hugepagesz=1G
EOF

# The VM definition
# The network is handled in macvtap bridge mode
# See https://hicu.be/bridge-vs-macvlan
# See https://ahelpme.com/linux/howto-do-qemu-full-virtualization-with-macvtap-networking/
CopyFile /etc/libvirt/qemu/Gaming.xml 600
## Autostart
CreateLink /etc/libvirt/qemu/autostart/Gaming.xml /etc/libvirt/qemu/Gaming.xml

