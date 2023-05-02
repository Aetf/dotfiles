# Homebrew
() {
    if [ -d $HOME/.linuxbrew ]; then
        eval "$($HOME/.linuxbrew/bin/brew shellenv)"
        #export HOMEBREW_FORCE_BREWED_CURL=1
        #export HOMEBREW_FORCE_BREWED_GIT=1
    fi
    if [ -d /opt/homebrew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        export HOMEBREW_NO_ANALYTICS=1
    fi
}

