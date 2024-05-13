SRC=$BASH_SOURCE
DIR=`dirname "$SRC"`

source "$DIR"/functions

mkmount /etc/pve/vip "$DIR/vip"