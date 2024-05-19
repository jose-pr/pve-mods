source /etc/pve/psql/profile
set -e


if ! is_quorate;then
    echo "Dont run PSQL as we dont have quorum"
    sudo systemctl stop postgresql repmgrd pgbouncer
    exit 0
fi

for service in postgresql pgbouncer;do
    if ! systemctl is-active "$service" > /dev/null;then
        sudo systemctl start "$service"
    fi
done

PSQL_PRIMARY_HOST=`current_psql_primary`
IS_PSQL_PRIMARY=`is_psql_primary && echo 'true' || echo 'false'`

parse_repmgr_csv 'REPMGR_' <<< "$(repmgr node status --csv 2> /dev/null)" || true  

echo "Current PSQL Primary is: $PSQL_PRIMARY_HOST"
echo "This node is primary: $IS_PSQL_PRIMARY"
echo "Assigned PSQL Role: $REPMGR_ROLE"

if  [ "$REPMGR_ROLE" = 'primary' ] && [ "$IS_PSQL_PRIMARY" = "false" ]; then
    echo "Failed Node, syncing to true primary"
    sudo systemctl stop postgresql repmgrd
    rm -f "$PSQL_DATA/recovery.conf"
    repmgr node rejoin -d "host=$PSQL_PRIMARY_HOST dbname=repmgr user=repmgr" --force-rewind
    sudo systemctl start postgresql repmgrd
    parse_repmgr_csv 'REPMGR_' <<< "$(repmgr node status --csv 2> /dev/null)" || true  
    IS_PSQL_PRIMARY=false
fi

DESIRED_MASTER=`psql -tAc "SELECT node_name FROM repmgr.nodes WHERE active=true ORDER BY priority DESC LIMIT 1" "$REPMGR_CONNINFO"`
echo "Desired PSQL Primary: $DESIRED_MASTER"

if  [ "$DESIRED_MASTER" = "$REPMGR_NODE_NAME" ] && [ "$IS_PSQL_PRIMARY" = 'false' ]; then
    echo "I am the desired Primary but not primary for PSQL performing swithover"
    repmgr standby switchover
fi

if ! systemctl is-active repmgrd > /dev/null;then
    echo "Starting repmgrd"
    sudo systemctl start repmgrd
fi
