#!/bin/bash
set -e

source /etc/pve/psql/profile

PSQL_HOME=`getent passwd postgres | cut -d: -f6`
PSQL_GID=`getent passwd postgres | cut -d: -f4`

echo "Cluster Config: $PSQL_CLUSTER_CONFIG"
echo "Local   Config: $PSQL_LOCAL_CONFIG"
echo "PSQL  Username:" $PSQL_USER
echo "$PSQL_USER HOME:" $PSQL_HOME
echo "$PSQL_USER GID:" $PSQL_GID

#
# Verify CONFIG
#
if ! [ -e "$PSQL_LOCAL_CONFIG/repmgr.conf" ] || ! [ -e "$PSQL_CLUSTER_CONFIG/repmgr.conf" ]; then
    echo "Missing REPMGR Config"
    exit 1
fi

source "$PSQL_LOCAL_CONFIG/repmgr.conf"
REPMGR_ID=$node_id
REPMGR_NAME=$node_name

if [ -z "$REPMGR_ID" ] || [ -z "$REPMGR_NAME" ]; then
    echo "Bad REPMGR Config"
    exit 1
fi

#
# PROFILE
#
cp -f "$PSQL_CLUSTER_PASSFILE" "$PSQL_HOME/.pgpass"
chown "$PSQL_USER":"$PSQL_GID" "$PSQL_HOME/.pgpass"
chmod 600 "$PSQL_HOME/.pgpass"

ln -sf "$PSQL_CLUSTER_CONFIG/profile" "$PSQL_HOME/.profile"
ln -sf "$PSQL_CLUSTER_CONFIG/profile" "$PSQL_HOME/.bashrc"

#
# CONFIGURE SSH
#
touch "$PSQL_CLUSTER_CONFIG/authorized_keys"

SSH_HOME="$PSQL_HOME/.ssh"
SSH_ID="$SSH_HOME/id_rsa"

mkdir -p "$SSH_HOME"
chown -R "$PSQL_USER":"$PSQL_GID" "$SSH_HOME"
chmod 700 "$SSH_HOME"
ln -sf "$PSQL_CLUSTER_CONFIG/authorized_keys" "$SSH_HOME/authorized_keys"
if ! [ -e "$SSH_ID" ]; then
    ssh-keygen -t rsa -N "" -f "$SSH_ID"
    chmod 600 "$SSH_ID"
fi
ID_PUB=`ssh-keygen -y -f "$SSH_ID" | cut -f1,2 -d ' '`

if ! cat "$PSQL_CLUSTER_CONFIG/authorized_keys" | grep -q "$ID_PUB";then
    echo  "$ID_PUB $REPMGR_NAME" >> "$PSQL_CLUSTER_CONFIG/authorized_keys"
fi

#
# Systemd
#
ln -fs "$PSQL_CLUSTER_CONFIG/systemd/repmgrd.service" /etc/systemd/system/
ln -fs "$PSQL_CLUSTER_CONFIG/systemd/postgresql.service" /etc/systemd/system/
ln -fs "$PSQL_CLUSTER_CONFIG/systemd/sudoers" /etc/sudoers.d/postgresql

# systemctl daemon-reload

#
# PSQL
#

#
# REPMGR
#
ln -fs "$REPMGR_CONF" "/etc/repmgr.conf"

#PGBOUNCER
ln -sf "$PGBOUNCER_INI"  "/etc/pgbouncer/pgbouncer.ini"
cp -f "$PGBOUNCER_USERLIST" "/etc/pgbouncer/userlist.txt"
chmod 600 "/etc/pgbouncer/userlist.txt"
chown "$PSQL_USER":"$PSQL_GID" "/etc/pgbouncer/userlist.txt"



