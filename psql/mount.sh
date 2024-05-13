SRC=$BASH_SOURCE
DIR=`dirname "$SRC"`
source /etc/pve/psql/profile


function mkmount(){
    echo "Mounting $1 at $2"
    mkdir -p "$2"
    mount --bind "$1" "$2"
}

mkmount "$PSQL_CLUSTER_CONFIG" "$DIR/config"
mkmount "$PSQL_LOCAL_CONFIG" "$DIR/local"
#mkmount "$PSQL_DATA" "$DIR/data"