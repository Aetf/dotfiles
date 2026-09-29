# Default to a UTF-8 locale when nothing set one. macOS has no system-wide
# locale: Terminal.app and iTerm export LANG themselves, so an ssh session from
# a client that doesn't forward LANG (SendEnv) otherwise runs in the C locale.
if [[ -z ${LANG-}${LC_ALL-}${LC_CTYPE-} ]]; then
    export LANG=en_US.UTF-8
fi
