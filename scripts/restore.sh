
echo "Restore database filesystem."
docker-compose \
--file ${LOCALENV_HOME}/docker-compose.shared.yml \
--file ${LOCALENV_HOME}/run/docker-compose.backup.yml \
run --rm \
--volume=$(pwd):/backup \
backup ash -c "cd /var/lib/mysql && tar xvf /backup/backup.tar --strip 1"
