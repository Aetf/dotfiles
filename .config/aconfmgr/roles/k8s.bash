AddPackage $FOREIGN k3s-1.25-bin
AddPackage kubectl
SystemdEnable k3s-1.25-bin /usr/lib/systemd/system/k3s.service

# Node feature isn't configuration
IgnorePath /etc/kubernetes/node-feature-discovery/*

# Tokens are private
IgnorePath /etc/rancher/k3s/*.token

# Juicefs volume plugin isn't isolated and will create this
IgnorePath /etc/updatedb.conf
