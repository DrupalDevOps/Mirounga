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

PROJECT_NAME="${PWD##*/}"

#
# === END DOCKER COMPOSE VARIALBES ===
#


# Create user-defined bridge, and pass name to Docker Compose.
export COMPOSE_NETWORK=VSD

NETEXISTS=`docker network ls | grep -c ${COMPOSE_NETWORK}`
if ! (($NETEXISTS)) ; then
  echo "Create user-defined network"
  docker network create --driver bridge --attachable ${COMPOSE_NETWORK}
  docker network inspect ${COMPOSE_NETWORK} | grep Attachable
else
  echo "Docker network ${COMPOSE_NETWORK} already exists, joining."
fi

echo "Running Docker Compose for VSD environment."


# Start shared services.
docker-compose \
--file ${LOCALENV_HOME}/docker-compose.shared.yml up --detach --no-recreate

# Start per-project stack, using current directory as project name.
# https://stackoverflow.com/a/1371283
docker-compose \
--project-name $PROJECT_NAME \
--file ${LOCALENV_HOME}/run/drupal/docker-compose.vsd.yml up --detach

# Show status.
docker-compose \
--file ${LOCALENV_HOME}/docker-compose.shared.yml \
ps
docker-compose \
--project-name $PROJECT_NAME \
--file ${LOCALENV_HOME}/run/drupal/docker-compose.vsd.yml \
ps

# Show where to find application.
# Docs
# - https://ss64.com/nt/cmd.html
# https://superuser.com/questions/1182275/how-to-use-start-command-in-bash-on-windows
# https://github.com/microsoft/terminal/issues/204#issuecomment-696816617

BROWSER_PORT=`docker-compose \
--project-name $PROJECT_NAME \
--file ${LOCALENV_HOME}/run/drupal/docker-compose.vsd.yml \
port nginx 8080 | sed 's/0.0.0.0/localhost/g'`

echo ""
echo "Your application is being served at ${BROWSER_PORT} !!"
echo ""

cmd.exe /c start chrome "http://${BROWSER_PORT}" 2> /dev/null

# Providing courtesy logs.
docker-compose \
--project-name $PROJECT_NAME \
--file ${LOCALENV_HOME}/docker-compose.shared.yml \
--file ${LOCALENV_HOME}/run/drupal/docker-compose.vsd.yml \
logs --follow nginx php-fpm varnish
