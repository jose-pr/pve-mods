```bash
K3S_DATASTORE_ENDPOINT='postgres://user:pass@vip:5432/k3sdb' 
source .privenv
mkdir -p /etc/pve/k3s
INSTALL_K3S_EXEC="--tls-san $CLUSTER_IP --disable=traefik --disable=servicelb"  INSTALL_K3S_VERSION=v1.28.9+k3s1 K3S_DATASTORE_ENDPOINT="$K3S_DATASTORE_ENDPOINT" K3S_TOKEN_FILE='/etc/pve/priv/k3s-token' INSTALL_K3S_SYSTEMD_DIR=/etc/pve/k3s bash /etc/pve/k3s/install.sh

mv  /var/lib/rancher/k3s/server/token /etc/pve/priv/k3s-token
ln -fs /etc/pve/priv/k3s-token /var/lib/rancher/k3s/server/token
mv /etc/systemd/system/k3s.service.env /etc/pve/k3s.env
ln -fs /etc/pve/k3s.env /etc/systemd/system/k3s.service.env

mv  /etc/rancher/k3s /etc/pve/local/
ln -fs /etc/pve/local/k3s /etc/rancher/k3s

kubectl create namespace cattle-system


helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

helm install rancher rancher-latest/rancher --namespace cattle-system --set hostname="$RANCHER_FQDN" --set tls=external   --set bootstrapPassword=admin --create-namespace

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

```