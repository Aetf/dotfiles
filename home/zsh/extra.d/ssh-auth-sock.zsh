# Make sure SSH_AUTH_SOCK points to a fixed location
if [[ -n $SSH_AUTH_SOCK && ! -h $SSH_AUTH_SOCK ]]; then
    mkdir -p $HOME/.ssh
    ln -sf $SSH_AUTH_SOCK $HOME/.ssh/ssh_auth_sock
    export SSH_AUTH_SOCK=$HOME/.ssh/ssh_auth_sock
elif [[ -z $SSH_AUTH_SOCK ]]; then
    export SSH_AUTH_SOCK=$HOME/.ssh/ssh_auth_sock
fi
