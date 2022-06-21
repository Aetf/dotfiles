# Use volta to manage nodejs
() {
    export VOLTA_HOME=$XDG_DATA_HOME/volta
    uprepend path "$VOLTA_HOME/bin"
}
