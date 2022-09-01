# Use fwupd to handle firmware upgrades
AddPackage fwupd
AddOptionalPackage fwupd \
    udisks2 "UEFI firmware upgrade support" # Disk Management Service, version 2
