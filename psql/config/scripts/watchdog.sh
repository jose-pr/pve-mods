source /etc/pve/psql/profile
set -e

if ! systemctl is-active postgresql > /dev/null;then
    echo "PSQL disabled skipping checks"
fi

IS_PVE_PRIMARY=$(jq ".master_node == \"`hostname`\"" /etc/pve/ha/manager_status)
PVE_PRIMARY=$(jq ".master_node" /etc/pve/ha/manager_status)
PSQL_PRIMARY_HOST=`get_psql_primary`
IS_PSQL_PRIMARY=false
for host in `hostname -i` `hostname` `hostname -f`;do
    if [ "$PSQL_PRIMARY_HOST" = "$host" ]; then
        IS_PSQL_PRIMARY=true
        break
    fi
done

parse_repmgr_csv 'REPMGR_' <<< "$(repmgr node status --csv 2> /dev/null)" || true  

echo "Current PVE Primary is: $PVE_PRIMARY"
echo "Current Primary Host is: $PSQL_PRIMARY_HOST"
echo "This node is primary for pve: $IS_PVE_PRIMARY psql: $IS_PSQL_PRIMARY"
echo "Assigned PSQL Role: $REPMGR_ROLE"

if  [ "$REPMGR_ROLE" = 'primary' ] && [ "$IS_PSQL_PRIMARY" = "false" ]; then
    echo "Failed Node, syncing to true primary"
    sudo systemctl stop postgresql
    rm -f "$PSQL_DATA/recovery.conf"
    repmgr node rejoin -d "host=$PSQL_PRIMARY_HOST dbname=repmgr user=repmgr" --force-rewind
fi

if  [ "$IS_PVE_PRIMARY" = 'true' ] && [ "$IS_PSQL_PRIMARY" = 'false' ]; then
    echo "I am HA Primary but not primary for PSQL performing swithover"
    repmgr standby switchover
fi

if ! systemctl is-active repmgrd > /dev/null;then
    echo "Starting repmgrd"
    sudo systemctl start repmgrd
fi
if ! systemctl is-active pgbouncer > /dev/null;then
    echo "Starting repmgrd"
    sudo systemctl start pgbouncer
fi
