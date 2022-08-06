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
