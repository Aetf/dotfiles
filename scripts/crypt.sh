#! /usr/bin/bash
#set -o xtrace
#set -o pipefail

log() {
    #echo "$@" >&2
    :
}

err() {
    echo "$@" >&2
}

target_attributes=('access_token' 'refresh_token' '//registry.npmjs.org/:_authToken')

isTargetLine() {
    local line="$1"
    for attr in "${target_attributes[@]}"; do
        attr="$attr="
        if [[ "${line:0:${#attr}}" == "$attr" ]]; then
            return 0
        fi
    done
    return 1
}

MAGIC="deadbeaf"
KEYFILE=".git/crypt-key"
OPENSSL_CIPHER="-aes-128-cbc -nosalt"

checkInit() {
    if [[ ! -f $KEYFILE ]]; then
        err "Keyfile $KEYFILE doesn't exist. You need run init first."
        exit 2
    fi
}

tryDecrypt() {
    log "tryDecrypt"

    checkInit

    local encrypted exitCode payload
    tryDecryptOut=

    encrypted="$1"

    # try base64 decode, we don't store the result, because bash is not good at handle binary data (espasically null byte)
    echo "$encrypted" | base64 -d 1>/dev/null 2>&1
    exitCode=$?
    if [[ $exitCode != 0 ]]; then
        return 1
    fi

    # gpg decrypt
    payload=$(echo "$encrypted" | base64 -d 2>/dev/null | openssl enc -d $OPENSSL_CIPHER -pass "file:$KEYFILE" 2>/dev/null)
    exitCode=$?
    if [[ $exitCode != 0 ]]; then
        return 1
    fi

    # match magic
    if [[ "${payload:0:${#MAGIC}}" != "$MAGIC" ]]; then
        return 1
    fi

    # ok for output
    tryDecryptOut="${payload#${MAGIC}}"
    return 0
}

encrypt() {
    log "encrypting"
    checkInit

    while IFS='$\n' read -r line; do
        if isTargetLine "$line"; then
            local key="${line%%=*}"
            local value="${line#*=}"
            if ! tryDecrypt "$value"; then
                # only encrypt if it is not already encrypted
                log "encrypting key $key"
                local payload="${MAGIC}${value}"
                local encrypted=$(echo "$payload" | openssl enc $OPENSSL_CIPHER -pass "file:$KEYFILE" 2>/dev/null | base64 -w 0 2>/dev/null)
                echo "$key=$encrypted"
                continue
            fi
        fi
        echo "$line"
    done

    log "encrypt done"
}

decrypt() {
    log "decrypting"
    checkInit

    while IFS='$\n' read -r line; do
        if isTargetLine "$line"; then
            local key="${line%%=*}"
            local encrypted="${line#*=}"
            if tryDecrypt "$encrypted"; then
                value="$tryDecryptOut"
                log "decrypted key $key"
                echo "$key=$value"
                continue
            fi
        fi
        echo "$line"
    done

    log "decrypt done"
}

do_diff() {
    log "do_diff"
    exec < "$1"
    decrypt
    log "do_diff done"
}

init() {
    git config --local filter.crypt.clean "crypt.sh enc"
    git config --local filter.crypt.smudge "crypt.sh dec"
    git config --local --bool filter.crypt.required "true"
    git config --local diff.crypt.textconv "crypt.sh diff"

    # generate key and store in kwallet
    if [[ -f "$KEYFILE" ]]; then
        err "The keyfile already exists: $KEYFILE"
        err "Remove it first if you want to regenerate"
    else
        openssl rand -out "$KEYFILE" 128
    fi
}

# Begins main
log "main"
act="$1"
shift

log "action is $act"

case $act in
    enc*)
        encrypt
        ;;
    dec*)
        decrypt
        ;;
    diff*)
        do_diff "$1"
        ;;
    init*)
        init "$@"
        ;;
    *)
        echo "Unknown action $act"
        exit 1
        ;;
esac
