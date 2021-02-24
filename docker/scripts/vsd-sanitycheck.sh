#!/bin/bash


# Allow script to be invoked from anywhere.
LOCALENV_HOME="/home/wsl/Sites/localenv"

#
# === START DOCKER COMPOSE VARIALBES ===
#

# Expected input by the php-fpm service, tells XDebug address where to find IDE.
# php-fpm service located in docker-compose.vsd.yml file.
# https://www.reddit.com/r/bashonubuntuonwindows/comments/c871g7/command_to_get_virtual_machine_ip_in_wsl2/
#
export XDEBUG_REMOTE_HOST=`ip addr show eth0 | grep -oE '\d+(\.\d+){3}' | head -n 1`
echo "XDebug will contact IDE at ${XDEBUG_REMOTE_HOST}"

# Source code directory, assumed to be the current directory.
export PROJECT_SOURCE=`readlink -f .`
echo "Project location is ${PROJECT_SOURCE}"

# Each application's docker compose needs to know the project's name
# in order to create per-project service aliases for Nginx, since
# multiple applications can join the shared VSD network to access the same database service.
export PROJECT_NAME="${PWD##*/}"

# Create user-defined bridge network, name is used by Docker Compose.
# Shared compose services (database) are shared across all applications joining this network.
export COMPOSE_NETWORK=VSD

#
# === END DOCKER COMPOSE VARIALBES ===
#


# Provide courtesy logs, and behold: The Glory Of Docker !
docker-compose \
--project-name $PROJECT_NAME \
--file ${LOCALENV_HOME}/docker-compose.shared.yml \
--file ${LOCALENV_HOME}/docker-compose.override.yml \
--file ${LOCALENV_HOME}/run/drupal/docker-compose.vsd.yml \
config
