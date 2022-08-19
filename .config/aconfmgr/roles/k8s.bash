AddPackage $FOREIGN k3s-1.24-bin
SystemdEnable k3s-1.24-bin /usr/lib/systemd/system/k3s.service

# Tokens are private
IgnorePath /etc/rancher/k3s/*.token
