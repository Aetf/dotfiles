
AddPackage openssh # Premier connectivity tool for remote login with the SSH protocol

# Allow local autorized keys in addition to distributed ones
cat > "$(CreateFile /etc/ssh/sshd_config.d/local-authorized-keys.conf)" <<EOF
AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys.local
EOF

# Some default security settings
cat > "$(CreateFile /etc/ssh/sshd_config.d/default-security.conf)" <<EOF
Port 59901
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
EOF

# Allow gpg-agent forwarding to delete stale UDS
cat > "$(CreateFile /etc/ssh/sshd_config.d/allow-uds-unlink.conf)" <<EOF
StreamLocalBindUnlink yes
EOF

# Tear down sessions whose client vanished (laptop slept, link dropped) so
# sshd-session exits and unlinks the agent socket it forwarded into
# ~/.ssh/agent. Otherwise that socket keeps listening but never answers, and
# every ssh that resolves ~/.ssh/ssh_auth_sock to it hangs.
cat > "$(CreateFile /etc/ssh/sshd_config.d/keepalive.conf)" <<EOF
ClientAliveInterval 30
ClientAliveCountMax 3
EOF

SystemdEnable openssh /usr/lib/systemd/system/sshd.service
