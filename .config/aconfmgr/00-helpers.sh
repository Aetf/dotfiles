# 00-helpers.sh

# Helper functions
function Host() {
    local host=$(uname -n)
    printf "$host"
}

function AbsolutePath() {
    local abs_path=$(cd -- "$(dirname -- "$1")" &> /dev/null && pwd)/$(basename -- "$1")
    printf "$abs_path"
}

function CallerName() {
    printf "$(AbsolutePath "${BASH_SOURCE[2]}")"
}

function AddRole() {
    local role=$1
    LogEnter 'Role %s...\n' "$(Color C "%q" "$role")"
    source "${config_dir}/roles/${role}.bash"
    LogLeave ''
}

# AddOptionalPackage optional-for depent reason
function AddOptionalPackage() {
    shift 1
    while (( "$#" )); do
        AddPackage "$1"
        shift 2
    done
}

#
# CopyFileTo SRC-PATH DST-PATH [MODE [OWNER [GROUP]]]
#
# Copies a file from the "<files>" subdirectory to the output,
# under a different name or path.
#
# <files> is defined as "files-$(Host)" if the source path exists, with a fallback
# of "files"
#
# The source path should be relative to the root of the "<files>" subdirectory.
# The destination path is relative to the root of the output directory.
#
# Note that the overwrites the function in aconfmgr with the same name

function CopyFileTo() {
    local src_file="$1"
    local dst_file="$2"
    local mode="${3:-}"
    local owner="${4:-}"
    local group="${5:-}"

    if [[ "$src_file" != /* ]]
    then
        ConfigWarning 'Source file path %s is not absolute.\n' \
                      "$(Color C "%q" "$src_file")"
    fi

    if [[ "$dst_file" != /* && "$dst_file" != "$src_file" ]]
    then
        ConfigWarning 'Target file path %s is not absolute.\n' \
                      "$(Color C "%q" "$dst_file")"
    fi

    local src_files_dirs=("files-$(Host)" 'files')
    local src_files_dir

    for src_files_dir in "${src_files_dirs[@]}"; do
        if [[ ! -e "$config_dir/$src_files_dir/$src_file" ]]; then
            continue
        fi

        if [[ -d "$config_dir/$src_files_dir/$src_file" ]]; then
            ( cd -- "$config_dir/$src_files_dir/$src_file" && find ! -type d -print0 ) | while read -r -d $'\0' line; do
                # Note that $line starts with ./
                line=${line:2}

                mkdir --parents "$(dirname "$output_dir"/files/"$dst_file/$line")"

                cp --no-dereference\
                   "$config_dir"/"$src_files_dir"/"$src_file"/"$line" \
                   "$output_dir"/files/"$dst_file"/"$line"

                SetFileProperty "$dst_file/$line" mode  "$mode"
                SetFileProperty "$dst_file/$line" owner "$owner"
                SetFileProperty "$dst_file/$line" group "$group"

                used_files["$src_file/$line"]=y
            done
        else
            mkdir --parents "$(dirname "$output_dir"/files/"$dst_file")"

            cp --no-dereference\
               "$config_dir"/"$src_files_dir"/"$src_file"\
               "$output_dir"/files/"$dst_file"

            SetFileProperty "$dst_file" mode  "$mode"
            SetFileProperty "$dst_file" owner "$owner"
            SetFileProperty "$dst_file" group "$group"

            used_files["$src_file"]=y
        fi

        return 0
    done

    ConfigWarning 'Skipped CopyFile due to nonexisting source: %s (tried files dir: %s)\n' \
        "$(Color C "%q" "$src_file")" \
        "$(Color C "%s" "${src_files_dirs[*]}" | tr "$IFS" ',')"
}

# SystemdEnable
#     [--no-alias|--no-wanted-by]
#     [--name CUSTOM_NAME]
#     [--type system|user]
#     [--from-file|package] unit
#
# Enable a systemd unit file.
#
# Caveat: This will not process Also directives, as it might in theory require
# handling files from other packages. In addition you might not want to install
# both this unit and the Also unit.
#
# --no-alias and --no-wanted-by can be used to disable installing those types of
# links. This is useful if you want to just use socket and dbus activation and
# don't want the unit to start on boot.
#
# --name is to be used for parameterised units ("foo@.service"), to provide the
# parameter.
#
# --type defaults to system but can be used to override and install default user
# units in /etc/systemd/user.
#
# --from-file is used when unit file is installed by aconfmgr instead of pulled
# from a package. In this case the package name MUST be skipped. Otherwise it is
# REQUIRED.
function SystemdEnable() {
    local type=system
    local do_alias=1 do_wanted_by=1 from_file=0

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --no-alias) do_alias=0 ;;
            --no-wanted-by) do_wanted_by=0 ;;
            --from-file) from_file=1 ;;
            --name)
                local name_override=$2
                shift 1
                ;;
            --type)
                type=$2
                shift 1
                ;;
            *)
                break
                ;;
        esac
        shift 1
    done

    if [[ $from_file -eq 0 ]]; then
        [[ $# -ne 2 ]] && FatalError "Expected 2 arguments, got $#."
        local pkg="$1"
        local unit="$2"
    else
        [[ $# -ne 1 ]] && FatalError "Expected 1 argument, got $#."
        local unit="$1"
    fi

    if [[ "$type" != "system" && "$type" != "user" ]]; then
        FatalError "Unkown type ${type}"
    fi

    local filename="${unit##*/}"

    # Find the unit, either from package data or already added to the output
    # directory
    if [[ $from_file -eq 0 ]]; then
        local unit_source="$tmp_dir/systemd_helpers/$pkg/$filename"

        if [[ ! -f "$unit_source" ]]; then
            mkdir -p "$tmp_dir/systemd_helpers/$pkg"
            AconfGetPackageOriginalFile "$pkg" "$unit" > "$unit_source"
        fi
    else
        local unit_source="$output_dir/files/$unit"
    fi

    [[ ! -f "$unit_source" ]] && FatalError "$unit_source not found"

    local target
    local oIFS="$IFS"
    # Process WantedBy lines (if enabled)
    if [[ $do_wanted_by -eq 1 ]]; then
        local name="${name_override:-${filename}}"
        local -a wantedby

        if grep -q WantedBy= "$unit_source"; then
            IFS=$' \n\t'
            wantedby=( $(grep -E '^WantedBy=' "$unit_source" | cut -d= -f2) )
            IFS="$oIFS"
            for target in "${wantedby[@]}"; do
                CreateLink "/etc/systemd/${type}/${target}.wants/${name}" "${unit}"
            done
        fi
    fi

    # Process Alias lines (if enabled)
    if [[ $do_alias -eq 1 ]]; then
        local -a aliases

        if grep -q Alias= "$unit_source"; then
            IFS=$' \n\t'
            aliases=( $(grep -E '^Alias=' "$unit_source" | cut -d= -f2) )
            IFS="$oIFS"
            for target in "${aliases[@]}"; do
                CreateLink "/etc/systemd/${type}/${target}" "${unit}"
            done
        fi
    fi
}

# SystemdMask unit-name [type]
#
# Mask a unit. Defaults to masking system units
function SystemdMask() {
    local unit="$1"
    local type="${2:-system}"

    if [[ "$type" != "system" && "$type" != "user" ]]; then
        FatalError "Unkown type ${type}"
    fi

    CreateLink "/etc/systemd/${type}/${unit}" /dev/null
}
