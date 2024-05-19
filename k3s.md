```bash
K3S_DATASTORE_ENDPOINT='postgres://user:pass@vip:5432/k3sdb' 
source .privenv
mkdir -p /etc/pve/k3s
INSTALL_K3S_EXEC="--disable traefik --tls-san $CLUSTER_IP"  K3S_DATASTORE_ENDPOINT="$K3S_DATASTORE_ENDPOINT" K3S_TOKEN_FILE='/etc/pve/priv/k3s-token' INSTALL_K3S_SYSTEMD_DIR=/etc/pve/k3s bash /etc/pve/k3s/install.sh

mv  /var/lib/rancher/k3s/server/token /etc/pve/priv/k3s-token
ln -fs /etc/pve/priv/k3s-token /var/lib/rancher/k3s/server/token
mv /etc/systemd/system/k3s.service.env /etc/pve/k3s.env
ln -fs /etc/pve/k3s.env /etc/systemd/system/k3s.service.env

mv  /etc/rancher/k3s /etc/pve/local/
ln -fs /etc/pve/local/k3s /etc/rancher/k3s

curl -sfL https://get.k3s.io | sh -s - server --datastore-endpoint="'postgres://user:pass@vip:5432/k3sdb"
```