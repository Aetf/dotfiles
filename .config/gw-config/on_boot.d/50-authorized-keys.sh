#!/bin/bash
# Ensure the managed public keys are present in root's authorized_keys.
#
# The keys' source of truth is the repo's authorized_keys.d/, deployed to
# /data/custom/authorized_keys.d by deploy.sh. /root has survived every
# observed firmware update (same undocumented migration as /etc), so this
# restore is insurance for a major-version jump or factory reset, on the
# same reasoning as 20-units.sh. Append-only and idempotent: keys added by
# hand on the box are left alone.

set -e

keydir=/data/custom/authorized_keys.d
[ -d "$keydir" ] || exit 0

mkdir -p /root/.ssh
chmod 700 /root/.ssh
touch /root/.ssh/authorized_keys

for pub in "$keydir"/*.pub; do
    [ -e "$pub" ] || continue
    grep -qxF "$(cat "$pub")" /root/.ssh/authorized_keys ||
        cat "$pub" >>/root/.ssh/authorized_keys
done

chmod 600 /root/.ssh/authorized_keys
