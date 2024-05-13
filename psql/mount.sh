SRC=$BASH_SOURCE
DIR=`dirname "$SRC"`
source /etc/pve/psql/profile
source "$DIR"/../functions

mkmount "$PSQL_CLUSTER_CONFIG" "$DIR/config"
mkmount "$PSQL_LOCAL_CONFIG" "$DIR/local"
mkmount "$PSQL_DATA" "$DIR/data"