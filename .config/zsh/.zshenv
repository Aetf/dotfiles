# Source ordering: .zshenv → [.zprofile if login] → [.zshrc if interactive] → [.zlogin if login] → [.zlogout sometimes]

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

# Get the absolute path to the caller's encolsing script.
# When called from another function, use the optional
# [NESTED] parameter to skip.
# Usage:
#   scriptpath [NESTED]
# Example:
#   scriptpath 1
# See https://stackoverflow.com/a/55172834
# See https://stackoverflow.com/a/28336473
function scriptpath() {
    local nested=${1:-0}

    # https://zsh.sourceforge.io/Doc/Release/Zsh-Modules.html#The-zsh_002fparameter-Module
    zmodload zsh/parameter

    # funcfiletrace gives the file path to the caller of the current function
    # when not nested, the first element is the caller, otherwise, add nested
    # levels.
    local level=1
    (( level = $level + $nested ))
    local caller="${funcfiletrace[$level]}"
    # remove the tailing line number, e.g. /path/to/script.zsh:3
    caller="${caller%:*}"
    # make it absolute, and resolve symlinks
    caller="${caller:A}"
    printf '%s' "$caller"
}

function indexer() {
    # caller of this function, so nested=1
    local caller=$(scriptpath 1)

    setopt null_glob

    # :h to remove the last path component, to get caller directory
    for f in ${caller:h}/*.zsh; do
        case $f in
            */index.zsh)
                continue
                ;;
            *)
                source "$f"
                ;;
        esac
    done
    # Also source direct level plugins
    for f in ${caller:h}/*/*.plugin.zsh; do
        source "$f"
    done
}
