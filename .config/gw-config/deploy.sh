#!/usr/bin/env bash
# Deploy gw-config to the UDM-SE gateway; --check does a dry-run diff only.
#
# The UDM's /etc is wiped by firmware updates. Everything managed here either
# lives under /data (survives updates) or is reinstalled from /data at boot by
# on_boot.d/0-setup-system.sh. This script pushes the yadm-managed sources of
# truth to both places.
#
# --check reports drift as an actual diff (repo = source of truth): for text
# files it prints a unified diff of the live copy on gw vs the repo copy; for
# metadata (mode) drift it prints the two values; and it names files that are
# missing on gw or would be deleted by an apply. The daily check-gw timer mails
# this, so it has to be readable without the raw rsync itemize codes.
set -euo pipefail
cd "$(dirname "$0")"
mode=${1:---apply}

# Source-of-truth -> gateway destination. A trailing slash means directory sync
# (with --delete); no trailing slash is a single file. Both the check and the
# apply path iterate this same list so they can never diverge.
pairs=(
    "on_boot.d/|/data/on_boot.d/"
    "nspawn/|/data/gw-config/nspawn/"
    "nspawn/|/etc/systemd/nspawn/"
    "caddy/Caddyfile|/data/caddy/config/caddy/Caddyfile"
    "containers/adguard/etc/systemd/network/80-container-host0.network.d/|/data/custom/machines/adguard/etc/systemd/network/80-container-host0.network.d/"
    "secrets/cf_token|/data/caddy/secrets/cf_token"
)

is_text() { LC_ALL=C grep -Iq . "$1" 2>/dev/null; }

# Render one drifted path (relative to the pair's dest dir) as a readable entry.
describe_change() {
    local code=$1 lpath=$2 rpath=$3
    # Never print secret material: check-gw mails this output.
    local secret=0
    [[ $lpath == secrets/* ]] && secret=1
    if [[ $code == '*deleting' ]]; then
        echo "  DELETE  $rpath"
        echo "          exists on gw, not in repo; apply would remove it"
        return
    fi
    local attrs=${code:2}   # the 9 'cstpoguax' attribute columns
    if [[ $attrs == '+++++++++' ]]; then
        echo "  NEW     $rpath"
        echo "          missing on gw; apply would create it"
        if (( ! secret )) && is_text "$lpath"; then sed 's/^/          + /' "$lpath"; fi
        return
    fi
    if [[ ${attrs:0:1} == c || ${attrs:1:1} == s ]]; then   # content differs
        echo "  CHANGED $rpath"
        if (( secret )); then
            echo "          content differs (secret, redacted)"
        elif is_text "$lpath"; then
            { diff -u --label "gw:$rpath (live)" --label "repo:$lpath (wanted)" \
                <(ssh -n gw cat -- "$rpath" 2>/dev/null) "$lpath" || true; } \
                | sed 's/^/          /'
        else
            echo "          binary content differs"
        fi
        return
    fi
    # Metadata-only drift. With our rsync flags (-p, no -o/-g/-t) this is
    # effectively always the permission bits.
    if [[ ${attrs:3:1} == p ]]; then
        local lmode rmode
        lmode=$(stat -c '%a' "$lpath" 2>/dev/null || echo '?')
        rmode=$(ssh -n gw stat -c '%a' -- "$rpath" 2>/dev/null || echo '?')
        echo "  MODE    $rpath"
        echo "          gw=$rmode  repo=$lmode  (apply sets $lmode)"
        return
    fi
    echo "  META    $rpath  ($code)"
}

report_pair() {
    local src=$1 dest=$2 out line change path lpath rpath
    out=$(rsync -rlpc --delete -ni "$src" "gw:$dest" 2>/dev/null || true)
    [[ -z ${out//[[:space:]]/} ]] && return 0
    while IFS= read -r line; do
        [[ -z $line ]] && continue
        read -r change path <<<"$line"
        if [[ $src == */ ]]; then
            lpath="$src$path"; rpath="$dest$path"
        else
            lpath="$src";      rpath="$dest"
        fi
        describe_change "$change" "$lpath" "$rpath"
    done <<<"$out"
    echo
}

if [[ $mode == --check ]]; then
    for p in "${pairs[@]}"; do
        report_pair "${p%%|*}" "${p##*|}"
    done
    exit 0
fi

# --apply
ssh gw 'mkdir -p /data/gw-config/nspawn' 2>/dev/null
flags=(-rlpc --delete --itemize-changes)
for p in "${pairs[@]}"; do
    rsync "${flags[@]}" "${p%%|*}" "gw:${p##*|}"
done
ssh gw 'chmod +x /data/on_boot.d/*.sh && systemctl daemon-reload' 2>/dev/null
echo "Applied. Caddyfile changes additionally need:"
echo "  ssh gw systemctl restart systemd-nspawn@caddy.service"
