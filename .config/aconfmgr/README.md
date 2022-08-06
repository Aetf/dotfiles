# Full system definitions

Sort-of declarative system config using `aconfmgr`.

## Aetf-Arch-XPS

### Partition layout

* The bottom layer is a 512GB partition
* The partition acts as a LVM PV
* The PV is allocated to LVM VG `ArchGroup`
* One LV is created in the VG
    + `cryptroot` 100%FREE
* LUKS container is created with in `cryptroot`
    + Protected by password
* Btrfs inside the LUKS
    + subvolume -> mount point
        - `@` -> `/`
        - `@home` -> `/home`
        - `@var` -> `/var`
        - `@root` -> `/root`
        - `@swapfiles` -> `/.swapfiles`
        - `@snapshots` -> `/.snapshots`
* The swap file is located at `/.swapfiles/hibernate`


#### Reasoning

The LVM is used so that we can extend and move partitions around even though Luks header can not be moved.
As the LVM maintains the mapping from PV blocks to LV blocks, and they can be nonlinear.

