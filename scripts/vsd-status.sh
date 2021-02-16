#!/bin/bash

# VSC, WSL, DD Start File.
#
# Script integrates (V)isual Studio Code, Windows (S)ubsystem for Linux, and (D)ocker Desktop.

# Using user-defined network eliminates need to use service links,
# and allows multiple compose stacks to join/leave network on a as-needed basis -
# as opposed to composing up or down an entire monolith compose stack.
#

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

echo "Running Docker Compose for VSD environment."


# Show status.
docker-compose \
--file ${LOCALENV_HOME}/docker-compose.shared.yml \
--file ${LOCALENV_HOME}/docker-compose.override.yml \
ps
docker-compose \
--project-name $PROJECT_NAME \
--file ${LOCALENV_HOME}/run/drupal/docker-compose.vsd.yml \
ps



BROWSER_PORT=`docker-compose \
--project-name $PROJECT_NAME \
--file ${LOCALENV_HOME}/run/drupal/docker-compose.vsd.yml \
port nginx 443 | sed 's/0.0.0.0/local.alexanderallen.name/g'`

VARNISH_BROWSER_PORT=`docker-compose \
--project-name $PROJECT_NAME \
--file ${LOCALENV_HOME}/run/drupal/docker-compose.vsd.yml \
port varnish 80 | sed 's/0.0.0.0/localhost/g'`

echo ""
echo "Your application is being served at ${BROWSER_PORT} !!"
echo ""

echo "Varnish is being served fresh at ${VARNISH_BROWSER_PORT}"
echo ""

# cmd.exe /c start chrome "https://${BROWSER_PORT}" 2> /dev/null
# cmd.exe /c start chrome "http://${VARNISH_BROWSER_PORT}" 2> /dev/null

# Provide courtesy logs, and behold: The Glory Of Docker !
docker-compose \
--project-name $PROJECT_NAME \
--file ${LOCALENV_HOME}/docker-compose.shared.yml \
--file ${LOCALENV_HOME}/docker-compose.override.yml \
--file ${LOCALENV_HOME}/run/drupal/docker-compose.vsd.yml \
logs --follow nginx php-fpm varnish
