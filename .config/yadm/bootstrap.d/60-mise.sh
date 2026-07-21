#!/usr/bin/env bash

# Install mise-managed global tools, including per-host project pins from
# the ~/.config/mise/conf.d/*.toml alternates, then run the host's
# projects:sync glue task if it defines one. The post_pull hook does the
# same on every pull; this covers the initial bootstrap.
set -eu

if ! command -v mise >/dev/null 2>&1; then
    echo "mise not installed; skipping tool installation" >&2
    exit 0
fi

mise install
if mise tasks ls 2>/dev/null | grep -q '^projects:sync'; then
    mise run projects:sync
fi
