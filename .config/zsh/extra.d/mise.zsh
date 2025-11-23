() {
    if whence -p mise &>/dev/null; then
        eval "$(mise activate zsh)"
    fi
}
