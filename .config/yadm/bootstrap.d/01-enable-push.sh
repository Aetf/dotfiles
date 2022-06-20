#!/usr/bin/env bash

enable_push() {
    local cmd=$1
    local origin=$("$cmd" remote get-url origin)
    local old="https://github.com/"
    local new="git@github.com:"
    origin="${origin/#$old/$new}"
    "$cmd" remote set-url origin "$origin"
}

main() {
    local subname=$1
    if [ -z "$subname" ]; then
        echo "Enabling push for yadm repo"
        enable_push yadm
        echo "Enabling push for submodules... "
        yadm submodule foreach "${BASH_SOURCE[0]} \$name"
        echo "Done"
    else
        enable_push git
    fi
}

main $@
