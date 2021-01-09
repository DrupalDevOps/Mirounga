#!/bin/bash

# Bring down stack if it exists.
ENV=${ENVIRONMENT:-vsd}
echo "Stop Docker Compose ${ENV} environment."

LOCALENV_HOME="/home/wsl/Sites/localenv"

# Backup database before tearing it down.
# https://docs.docker.com/storage/volumes/#backup-a-container
echo "Back up database filesystem."
docker-compose \
--file ${LOCALENV_HOME}/docker-compose.shared.yml \
--file ${LOCALENV_HOME}/run/docker-compose.backup.yml \
run --rm \
--volume=$(pwd):/backup \
backup ash -c "tar cf /backup/backup.tar /var/lib/mysql"

# Remove shared services.
echo "Remove shared services."
docker-compose \
--file ${LOCALENV_HOME}/docker-compose.shared.yml down -v --remove-orphans

# Remove per-project stack, using current directory as project name.
echo "Remove project services."
docker-compose \
--project-name "${PWD##*/}" \
--file ${LOCALENV_HOME}/run/drupal/docker-compose.vsd.yml down

# Cleanup while we're at it.
docker system prune --force

echo "Remove user bridge network."
docker network rm VSD
