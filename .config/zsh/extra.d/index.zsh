() {
    0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"

    for f in ${0:h}/*.zsh; do
        case $f in
            */index.zsh)
                continue
                ;;
            *)
                source "$f"
                ;;
        esac
    done
}
