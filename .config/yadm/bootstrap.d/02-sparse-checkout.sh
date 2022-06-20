#!/usr/bin/env bash

main() {
    # sparse checkout must be run from toplevel
    cd "$(yadm rev-parse --show-toplevel)"

    echo "Configuring sparse checkout"
    # first disable sparse checkout to allow any updates in config
    # sparse-checkout will upgrade git config to use per-worktree config
    yadm sparse-checkout disable
    # enable sparse checkout
    yadm gitconfig --worktree core.sparseCheckout true
    # the $GIT_DIR/info/sparse-checkout file is already tracked by yadm
    # so just reapply to make it take effect
    yadm sparse-checkout reapply
}

main
