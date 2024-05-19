SRC=$BASH_SOURCE
DIR=`dirname "$SRC"`

source "$DIR"/functions

mkmount /etc/pve/vip "$DIR/vip"
mkmount /etc/pve/nginx "$DIR/nginx"

mkmount /etc/pve/k3s "$DIR/k3s/config"
mkmount /etc/pve/local/k3s "$DIR/k3s/local"