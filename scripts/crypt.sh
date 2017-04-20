#! /usr/bin/bash
#set -o xtrace
#set -o pipefail

log() {
    #echo "$@" >&2
    :
}

target_attributes=('access_token' 'refresh_token')

isTargetLine() {
    local line=$1
    for attr in "${target_attributes[@]}"; do
        attr="$attr="
        if [[ "${line:0:${#attr}}" == "$attr" ]]; then
            return 0
        fi
    done
    return 1
}

MAGIC="deadbeaf"
tryDecrypt() {
    log "tryDecrypt"

    local encrypted base64decoded exitCode payload
    tryDecryptOut=

    encrypted=$1

    # base64 decode
    base64decoded=$(echo "$encrypted" | base64 -d 2>/dev/null)
    exitCode=$?
    if [[ $exitCode != 0 ]]; then
        return 1
    fi

    # gpg decrypt
    payload=$(echo "$base64decoded" | gpg --decrypt 2>/dev/null)
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

    while IFS='$\n' read -r line; do
        if isTargetLine "$line"; then
            local key="${line%%=*}"
            local value="${line#*=}"
            if ! tryDecrypt "$value"; then
                # only encrypt is it is not already encrypted
                local payload="${MAGIC}${value}"
                local encrypted=$(echo "$payload" | gpg --encrypt --recipient Aetf 2>/dev/null | base64 -w 0 2>/dev/null)
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

    while IFS='$\n' read -r line; do
        if isTargetLine "$line"; then
            local key="${line%%=*}"
            local encrypted="${line#*=}"
            if tryDecrypt "$encrypted"; then
                value="$tryDecryptOut"
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
    exec < $1
    decrypt
    log "do_diff done"
}

init() {
    git config --local filter.crypt.clean "crypt.sh enc"
    git config --local filter.crypt.smudge "crypt.sh dec"
    git config --local --bool filter.crypt.required "true"
    git config --local diff.crypt.textconv "crypt.sh diff"
}

# Begins main
log "main"
act=$1
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
        do_diff $1
        ;;
    init*)
        init
        ;;
    *)
        echo "Unknown action $act"
        exit 1
        ;;
esac
