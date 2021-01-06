#!/bin/bash

# Bring down stack if it exists.
ENV=${ENVIRONMENT:-vsd}
echo "Stop Docker Compose ${ENV} environment."

LOCALENV_HOME="/home/wsl/Sites/localenv"

# Start shared services.
docker-compose \
--file ${LOCALENV_HOME}/docker-compose.shared.yml down

# Start per-project stack, using current directory as project name.
# https://stackoverflow.com/a/1371283
docker-compose \
--project-name "${PWD##*/}" \
--file ${LOCALENV_HOME}/run/drupal/docker-compose.vsd.yml down

echo "Remove user bridge network."
docker network rm VSD
