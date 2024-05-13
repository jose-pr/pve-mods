set -e
source /etc/pve/psql/profile

bash "$PSQL_SCRIPTS/setup.sh"

su -c "\"$PSQL_BIN/createdb\" repmgr" -l $PSQL_USER 2> /dev/null || true
su -c "psql -f \"$PSQL_SCRIPTS/update_user.sql\" -v 'username=repmgr'"  -l $PSQL_USER > /dev/null


