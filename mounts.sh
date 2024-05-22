SRC=$BASH_SOURCE
DIR=`dirname "$SRC"`
source /etc/pve/psql/profile
source "$DIR"/functions

mkmount "$PSQL_CLUSTER_CONFIG" "$DIR/psql/config"
mkmount "$PSQL_LOCAL_CONFIG" "$DIR/psql/local"
mkmount "$PSQL_DATA" "$DIR/psql/data"

mkmount /etc/pve/vip "$DIR/vip/global"
mkmount /etc/pve/nginx "$DIR/nginx/global"

mkmount /etc/pve/k3s "$DIR/k3s/config"
mkmount /etc/pve/local/k3s "$DIR/k3s/local"