#!/usr/bin/env bash

# The yadm repo's own config (repo.git/config) lives inside the git dir
# and cannot be tracked. Shared settings (aliases, etc.) live in the
# tracked ~/.config/yadm/gitconfig instead; this wires it in.
set -eu

echo "Including shared gitconfig into yadm repo config"
yadm gitconfig include.path "~/.config/yadm/gitconfig"
