#! /bin/sh

# Default values
REFIND_INSTALL_SCRIPT=/usr/bin/refind-install
MAX_RETRY=2
RETRY_WAIT=5s

# Global value
SOMETHING_WRONG=

#
# Purpose: Display message on stderr
#
info() {
    echo "[INFO]: $@" >&2
}
err() {
    echo "[ERROR]: $@" >&2
    SOMETHING_WRING=1
}
warning() {
    echo "[WARN]: $@" >&2
}

# Purpose: Display message and die with given exit code
# 
die(){
    local message="$1"
    local exitCode=$2
    err "$message"
    [ "$exitCode" == "" ] && exit 1 || exit $exitCode
}

#
# Purpose: Is script run by root? Else die..
# 
is_user_root(){
    [ "$(id -u)" != "0" ] && die "You must be root to run this script" 2
}

mountPathForBoot() {
    findmnt -n -o SOURCE -T /boot | sed -r 's/^.*\[(.*)\].*$/\1/'
}

clean() {
    info "Restore /boot previous mount status"
    umount /boot

    info "Remove unneeded conf file"
    rm -f /esp/*.conf
    if [ -d /esp/EFI/refind/icons-backup ]; then
        if diff -q /esp/EFI/refind/icons /esp/EFI/refind/icons-backup > /dev/null; then
            info "Remove identical icons-backup"
            rm -rf /esp/EFI/refind/icons-backup
        fi
    fi
}

setup() {
    #info "Umount anything on /boot"
    #while umount /boot; do continue; done

    info "Mount ESP on /boot"
    mount -o bind /esp /boot
}

ensureScript() {
    local count=0
    while [ ! -x "$REFIND_INSTALL_SCRIPT" ]; do
        count=$(($count+1))
        warning "Waiting for $REFIND_INSTALL_SCRIPT to be ready for 5 seconds"
        sleep 5s

        if [ $count -ge $MAX_RETRY ]; then
            err "Exceeded max retry times, abort"
            return 1
        fi
    done
    return 0
}

tryInstall() {
    if ensureScript; then
        info "Install refind"
        "$REFIND_INSTALL_SCRIPT"
    fi
}

main() {
    setup
    tryInstall
    clean

    if [ -n $SOMETHING_WRONG ]; then
        return 1
    fi
}

main $@
