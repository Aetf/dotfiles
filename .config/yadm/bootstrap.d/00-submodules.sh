#!/usr/bin/env bash

main() {
    # Because Git submodule commands cannot operate without a work tree, they must
    # be run from within toplevel folder
    cd "$(yadm rev-parse --show-toplevel)"

    echo "Init submodules"
    yadm submodule update --recursive --init --remote
    yadm smundetach
}

main
