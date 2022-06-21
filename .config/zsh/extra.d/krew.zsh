alias k='kubectl'
KREW_ROOT="$XDG_DATA_HOME/krew"
# Kubectl plugin manager https://krew.sigs.k8s.io
if [ -d "$KREW_ROOT" ]; then
    export KREW_ROOT
    uappend path "$KREW_ROOT/bin"
fi
