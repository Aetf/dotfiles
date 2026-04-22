
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

SystemdEnable openssh /usr/lib/systemd/system/sshd.service
