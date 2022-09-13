#!/usr/bin/env bash

main() {
    # Because Git submodule commands cannot operate without a work tree, they must
    # be run from within toplevel folder
    cd "$(yadm rev-parse --show-toplevel)"

    # Disable work submodule outside of work
    yadm gitconfig 'submodule..config/work.active' false

    echo "Init submodules"
    yadm submodule update --recursive --init --remote
    # for each submodule, checkout the branch configured in .gitmodules
    yadm smundetach
}

main
