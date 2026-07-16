() {
  local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/environment.d"
  local marker_env="ENV_D_SOURCED_MARKER"

  [[ -n ${(P)marker_env} || ! -d $config_dir ]] && return
  local cfg_files=("$config_dir"/*.conf(N))
  (( $#cfg_files == 0 )) && return

  # Automatically export any variable that gets assigned from this point forward
  setopt localoptions allexport

  local file
  for file in $cfg_files; do
    source "$file"
  done
}
