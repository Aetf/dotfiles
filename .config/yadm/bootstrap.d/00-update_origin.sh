#!/usr/bin/env bash

main() {
    local origin=$(yadm remote get-url origin)
    local old="https://github.com/"
    local new="git@github.com:"
    origin="${origin/#$old/$new}"
    echo "Updating the yadm repo origin URL to $origin"
    yadm remote set-url origin "$origin"
}

main
