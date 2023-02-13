# Move some dotfiles from home directory

## NodeJS repl history file .node_repl_history
export NODE_REPL_HISTORY=$XDG_CACHE_HOME/node/repl_history

## .bash_history
export HISTFILE=$XDG_CACHE_HOME/bash/history

## .python_history
export PYTHONHISTFILE=$XDG_CACHE_HOME/python/history

## .sqlite_history
export SQLITE_HISTORY=$XDG_CACHE_HOME/sqlite/history

## .wgetrc (which contains settings for hist-file .wget-hsts)
export WGETRC=$XDG_CONFIG_HOME/wget/wgetrc

## GnuPG
export GNUPGHOME=$XDG_DATA_HOME/gnupg

## Zoom
export SSB_HOME=$XDG_DATA_HOME/zoom

## AWS
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME"/aws/credentials
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME"/aws/config

## Rust
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup

## Conan
export CONAN_USER_HOME="$XDG_CONFIG_HOME"

## Docker
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker

## NPM
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc

## Jupyter/IPython
export IPYTHONDIR="$XDG_CONFIG_HOME"/ipython
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME"/jupyter

## Nuget
export NUGET_PACKAGES="$XDG_CACHE_HOME"/NuGetPackages

## KDE4
export KDEHOME="$XDG_CONFIG_HOME"/kde4

## gtk 2
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc

## kubectl
export KUBECONFIG="$XDG_CONFIG_HOME/kube/config"

## Boto used by gcloud
## https://cloud.google.com/storage/docs/boto-gsutil
export BOTO_CONFIG="$XDG_CONFIG_HOME/gcloud/boto.cfg"
