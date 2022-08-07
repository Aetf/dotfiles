# Full system definitions

Sort-of declarative system config using `aconfmgr`.

## Extra featues
I'm using some extra tricks to ease the management of multiple machines in addition to what's available
out-of-the-box from aconfmgr.

### Per-host configs
After defined in `20-hosts.sh`, each `*.sh` config script can include a `MatchHost || return 0` statement
in the beginning of the file. The function will check the hostname (`uname -n`) of the running system
and only proceed if the script filename matches the hostname.

### Per-host files
`00-helpers.sh` redefines `CopyFileTo` from aconfmgr helpers, to extend its file finding procedures.

Originally, `CopyFileTo` tries to locate src files from the `files` subfolder, given an absolute path
which acts as both the location within the `files` subdirectory and the final destination location in the
system.

The enhanced version will first prefer to find the src file from a host specific `files-$(uname -n)` subfolder,
and uses `files` as a fallback if the former one not found. This allows seamless per-host override of files
without ugly host suffix or different syntax.

### Recursive copy
`CopyFileTo` additionally has been enhanced to work with directories directly. If the path specified is a directory,
every files from that specific path inside the `files` (or `files-$(uname -n)`) subfolder will be considered,
with correct recording of whether the file is used or not, so `aconfmgr check` still works.

## Host specific notes
### Aetf-Arch-XPS

The LVM is used so that we can extend and move partitions around even though Luks header can not be moved.
As the LVM maintains the mapping from PV blocks to LV blocks, and they can be nonlinear.

#### Partition layout

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

