set -eo pipefail

echo ""
echo "Starting MariaDB Server"
echo ""

#
# Daemon options
#
# MYSQLD_OPTS="--user=${CONTAINER_USER}"
MYSQLD_OPTS="${MYSQLD_OPTS} --skip-name-resolve"
MYSQLD_OPTS="${MYSQLD_OPTS} --skip-host-cache"
MYSQLD_OPTS="${MYSQLD_OPTS} --skip-slave-start"
# Listen to signals, most importantly CTRL+C
MYSQLD_OPTS="${MYSQLD_OPTS} --debug-gdb"

# Do we really have to run this as root? Why can't we use su-exec.
su-exec ${CONTAINER_USER} /usr/bin/mysqld ${MYSQLD_OPTS}
