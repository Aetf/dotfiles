# Make sure everything is read from $XDG_CONFIG_HOME
export ZDOTDIR=${XDG_CONFIG_HOME:-$HOME/.config}/zsh

# Stable unique append and prepend, won't change order if the value is present
function uprepend() {
    local varname=$1
    local x=$2
    if [[ ${${(P)varname}[(ie)$x]} -gt ${#${(P)varname}} ]]; then
        typeset -g "${varname}[1, 0]=$x"
    fi
}

function uappend() {
    local varname=$1
    local x=$2
    if [[ ${${(P)varname}[(ie)$x]} -gt ${#${(P)varname}} ]]; then
        eval "${varname}+=(${x})"
    fi
}

function autodetect_path() {
    local pkg=$1

    local inc_dir=$pkg/include
    local bin_dir=$pkg/bin
    local lib_dir=$pkg/lib
    local lib64_dir=$pkg/lib64
    local sbin_dir=$pkg/sbin
    local man_dir=$pkg/share/man

    if [ -d $inc_dir ]; then
        uprepend include $inc_dir
        uprepend cpath $inc_dir
    fi
    if [ -d $bin_dir ]; then
        uprepend path $bin_dir
    fi
    if [ -d $sbin_dir ]; then
        # sbin comes after bin
        uappend path $sbin_dir
    fi
    if [ -d $lib_dir ]; then
        uprepend ld_library_path $lib_dir
        uprepend lib $lib_dir
        uprepend library_path $lib_dir
    fi
    if [ -d $lib64_dir ]; then
        uprepend ld_library_path $lib64_dir
        uprepend lib $lib64_dir
        uprepend library_path $lib64_dir
    fi

    if [ -d $man_dir ]; then
        uprepend manpath $man_dir
    fi

    # (FN): F means full dir (non-empty dir)
    # N means NULL_GLOB, i.e. it expands to nothing, rather than expands to literal value
    for cmake_dir in $pkg/share/*/cmake(FN); do
        uappend cmake_prefix_path $pkg
    done
    for pkgconfig_dir in $pkg/lib*/pkgconfig(FN); do
        uappend pkg_config_path $pkgconfig_dir
    done
}
