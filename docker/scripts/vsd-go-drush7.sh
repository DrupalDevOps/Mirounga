#!/bin/bash

export COMPOSE_NETWORK=VSD

export XDEBUG_REMOTE_HOST=`ip addr show eth0 | grep -oE '\d+(\.\d+){3}' | head -n 1`
echo "XDebug will contact IDE at ${XDEBUG_REMOTE_HOST}"

# Source code directory, assumed to be the current directory.
export PROJECT_SOURCE=`readlink -f .`
echo "Project location is ${PROJECT_SOURCE}"

# Must mount source into same location as PHP-FPM and Nginx.
export PROJECT_DEST="/vsdroot"

PROJECT_NAME="${PWD##*/}"
LOCALENV_HOME="."

# Sharing SSH socket from WSL2 into containers.
export SSH_AUTH_SOCK=${SSH_AUTH_SOCK}

# Merge Drush compose onto existing stack definition.
# Paths are relative to project root, when invoking script from project root.
docker-compose \
--project-name $PROJECT_NAME \
--file ${LOCALENV_HOME}/docker-compose.shared.yml \
--file ${LOCALENV_HOME}/docker-compose.override.yml \
--file ${LOCALENV_HOME}/docker-compose.vsd-go-drupal.yml \
--file ${LOCALENV_HOME}/docker-compose.vsd-go-drush.yml \
run \
--entrypoint=ash --rm --user=root \
drush7

#run --rm drush "$@"
# run --rm --user=root drush "$@"

# To connect to database use:
# mariadb -h mysql
