# Jiahui's account for photo work over ssh.
#
# Her laptop's Claude Code runs immich-go and the homelab-skills scripts here,
# next to the NAS and immich, so originals never cross the network twice. The
# account only exists to run commands inside a bubblewrap sandbox that sees the
# system read-only, Photos/Media/homelab-skills read-only, and her own home.
#
# Keys are added without anyone touching this machine: the laptop POSTs its
# public key to an HA webhook, Jiahui approves the push notification on her
# phone, and HA runs the chored job `jiahui-ssh-key` (yadm,
# ~/.config/chored/bin/jiahui-ssh-key). chored jobs run as aetf, so the key
# file is aetf-owned under /var/lib and sshd reads it through
# AuthorizedKeysCommand; StrictModes would reject it as ~jiahui/.ssh content.
#
# MANUAL after the first apply: systemd-sysusers && systemd-tmpfiles --create
# (sysusers/tmpfiles only run on package hooks), then systemctl reload sshd.

AddPackage bubblewrap # Unprivileged sandboxing tool

cat > "$(CreateFile /etc/sysusers.d/jiahui.conf)" <<EOF
u jiahui 1001 "Jiahui (photo work over ssh)" /home/jiahui /bin/bash
EOF

cat > "$(CreateFile /etc/tmpfiles.d/jiahui-photos.conf)" <<EOF
d /home/jiahui 0700 jiahui jiahui -
d /var/lib/jiahui-photos 0755 aetf aetf -
f /var/lib/jiahui-photos/authorized_keys 0644 aetf aetf -
EOF

# Sorts after every other drop-in: an unterminated Match would otherwise
# capture the directives of the files included after it.
cat > "$(CreateFile /etc/ssh/sshd_config.d/zz-jiahui-photos.conf)" <<EOF
Match User jiahui
    AuthorizedKeysFile none
    AuthorizedKeysCommand /usr/bin/cat /var/lib/jiahui-photos/authorized_keys
    AuthorizedKeysCommandUser nobody
    ForceCommand /usr/local/lib/jiahui-photos/shell
    AllowTcpForwarding no
    AllowStreamLocalForwarding no
    AllowAgentForwarding no
    X11Forwarding no
    PermitTunnel no
    PermitTTY no
EOF

cat > "$(CreateFile /usr/local/lib/jiahui-photos/shell 755)" <<'EOF'
#!/bin/bash
# ForceCommand for user jiahui (aconfmgr role jiahui-photos): run the ssh
# command in a sandbox that sees only what photo work needs.
set -euo pipefail
# Her own files in immich's storage (originals as immich stores them), so
# health scans see what actually landed in the library. The id is her immich
# user id; storage is laid out per user.
IMMICH=/mnt/nas/Immich
IMMICH_USER=ecb26aed-1627-4a94-81b8-6e29de1da01f
if [[ -z ${SSH_ORIGINAL_COMMAND:-} ]]; then
    echo "This account only runs commands: ssh homelab-photos '<command>'" >&2
    exit 2
fi
exec /usr/bin/bwrap \
    --ro-bind /usr /usr \
    --symlink usr/bin /bin --symlink usr/bin /sbin \
    --symlink usr/lib /lib --symlink usr/lib /lib64 \
    --ro-bind /etc /etc \
    --tmpfs /etc/rancher \
    --proc /proc --dev /dev --tmpfs /tmp --tmpfs /run \
    --ro-bind-try /run/systemd/resolve /run/systemd/resolve \
    --ro-bind /mnt/nas/Photos /mnt/nas/Photos \
    --ro-bind /mnt/nas/Media /mnt/nas/Media \
    --ro-bind /mnt/nas/homelab-skills /mnt/nas/homelab-skills \
    --ro-bind "$IMMICH/library/$IMMICH_USER" "$IMMICH/library/$IMMICH_USER" \
    --ro-bind "$IMMICH/upload/$IMMICH_USER" "$IMMICH/upload/$IMMICH_USER" \
    --bind "$HOME" "$HOME" --chdir "$HOME" \
    --unshare-pid --unshare-ipc --unshare-uts \
    --die-with-parent --new-session \
    /bin/bash -c "$SSH_ORIGINAL_COMMAND"
EOF
