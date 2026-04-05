# Install syslog-ng and make the host a remote log sink by listening on UDP port 514.
# Note that this intentionally do NOT interact with local logs at all, which
# should still be handled by systemd-journald.

# The main syslog-ng
AddPackage syslog-ng # Next-generation syslogd with advanced networking and filtering capabilities

## Enable the daemon
CopyFile /etc/default/syslog-ng@remote-only
SystemdEnable --name syslog-ng@remote-only.service syslog-ng /usr/lib/systemd/system/syslog-ng@.service

## The remote only config file
CopyFile /etc/syslog-ng/remote-only.conf

# Make sure destination files are rotated
AddPackage logrotate # Rotates system logs automatically
CopyFile /etc/logrotate.d/syslog-remote
SystemdEnable logrotate /usr/lib/systemd/system/logrotate.timer
