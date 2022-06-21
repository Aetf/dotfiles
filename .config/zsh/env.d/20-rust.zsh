# Rust language
() {
    local cargo_bin=${CARGO_HOME:-$HOME/.cargo}/bin
    if [ -d $cargo_bin ]; then
        uappend path $cargo_bin
    fi
}
