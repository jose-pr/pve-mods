#!/bin/bash
set -e

source /etc/pve/psql/profile

#
# Verify CONFIG
#
if ! [ -e "$PSQL_LOCAL_CONFIG/repmgr.conf" ] || ! [ -e "$PSQL_CLUSTER_CONFIG/repmgr.conf" ]; then
    echo "Missing REPMGR Config"
    exit 1
fi

load_psql_conf "$PSQL_LOCAL_CONFIG/repmgr.conf" "REPMGR_"

if [ -z "$REPMGR_NODE_ID" ] || [ -z "$REPMGR_NODE_NAME" ]; then
    echo "Bad REPMGR Config"
    exit 1
fi

RELOAD=0
#
# PROFILE
#
if filesync "$PSQL_CLUSTER_PASSFILE" "$PSQL_HOME/.pgpass";then
    echo "Update pgpass"
    chown "$PSQL_USER":"$PSQL_GID" "$PSQL_HOME/.pgpass"
    chmod 600 "$PSQL_HOME/.pgpass"
fi
if filesync "$PSQL_CLUSTER_CONFIG/profile"  "$PSQL_HOME/.profile";then
    echo "Updated profile"
    ln -sf "$PSQL_CLUSTER_CONFIG/profile" "$PSQL_HOME/.bashrc"
fi
if filesync "$PSQL_SCRIPTS/watchdog.sh"  "$PSQL_HOME/watchdog.sh";then
    echo "Updated watchdog"
    chmod 755 "$PSQL_HOME/watchdog.sh"
fi



#
# CONFIGURE SSH
#
touch "$PSQL_CLUSTER_CONFIG/authorized_keys"

SSH_HOME="$PSQL_HOME/.ssh"
SSH_ID="$SSH_HOME/id_rsa"

mkdir -p "$SSH_HOME"
chown -R "$PSQL_USER":"$PSQL_GID" "$SSH_HOME"
chmod 700 "$SSH_HOME"

if filesync "$PSQL_CLUSTER_CONFIG/authorized_keys"  "$SSH_HOME/authorized_keys";then
    echo "Updated authorized_keys"
fi

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
for unit in "$PSQL_CLUSTER_CONFIG/systemd/"*.{service,timer};do
    if filesync "$unit" "/etc/systemd/system/$(basename "$unit")"; then
        RELOAD=1
    fi
done
if filesync "$PSQL_CLUSTER_CONFIG/systemd/sudoers" /etc/sudoers.d/postgresql; then
    echo "Updating sudoers"
fi

if [ "$RELOAD" = "1" ]; then
    echo "Reloading systemd units"
    systemctl daemon-reload
fi


#
# REPMGR
#
ln -fs "$REPMGR_CONF" "/etc/repmgr.conf"

#PGBOUNCER
ln -sf "$PGBOUNCER_INI"  "/etc/pgbouncer/pgbouncer.ini"
if filesync "$PGBOUNCER_USERLIST" "/etc/pgbouncer/userlist.txt"; then
    chmod 600 "/etc/pgbouncer/userlist.txt"
    chown "$PSQL_USER":"$PSQL_GID" "/etc/pgbouncer/userlist.txt"
fi



