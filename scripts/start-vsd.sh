#!/bin/bash

# VSC, WSL, DD Start File.
#
# Script integrates (V)isual Studio Code, Windows (S)ubsystem for Linux, and (D)ocker Desktop.
# The name of the environment is VSD.

# Using user-defined network eliminates need to use service links,
# and allows multiple compose stacks to join/leave network on a as-needed basis -
# as opposed to composing up or down an entire monolith compose stack.
#
# For benefits of user-defined bridge over default bridge https://docs.docker.com/network/bridge/
# Compose networking: https://docs.docker.com/compose/networking/
# Latest compose reference: https://docs.docker.com/compose/compose-file/#network-configuration-reference

#
# === START DOCKER COMPOSE VARIALBES ===
#

# Expected input by the php-fpm service, tells XDebug address where to find IDE.
# php-fpm service located in docker-compose.vsd.yml file.
# https://www.reddit.com/r/bashonubuntuonwindows/comments/c871g7/command_to_get_virtual_machine_ip_in_wsl2/
#
export XDEBUG_REMOTE_HOST=`ip addr show eth0 | grep -oE '\d+(\.\d+){3}' | head -n 1`
echo "XDebug will contact IDE at ${XDEBUG_REMOTE_HOST}"

# Source code directory, to be found inside WSL Host.
# The directory from where the start script is invoked is assumed to be the project root.
#export PROJECT_ROOT=`pwd`

# export PROJECT_ROOT="/home/wsl/drupal-8.8.1"
export PROJECT_ROOT="/home/wsl/hello-php"


# Location to mount into the containers (php-fpm, nginx, drush).
export PROJECT_DEST="/sites"

#
# === END DOCKER COMPOSE VARIALBES ===
#




# Create user-defined bridge, and pass name to Docker Compose.
export COMPOSE_NETWORK=VSD

NETEXISTS=`docker network ls | grep -c $COMPOSE_NETWORK`
if ! (($NETEXISTS)) ; then
  echo "Create user-defined network"
  docker network create $COMPOSE_NETWORK
else
  echo "Docker network ${COMPOSE_NETWORK} already exists, joining."
fi

# Start stack by default on production configuration (minimal containers w/ no debugging).
# Switch ENVIRONMENT to dev to enable debugging.
ENV=${ENVIRONMENT:-vsd}
echo "Running Docker Compose for ${ENV} environment."

docker-compose \
-f docker-compose.yml \
-f run/drupal/docker-compose.${ENV}.yml \
up -d

docker-compose ps

# docker-compose \
# -f docker-compose.yml \
# -f run/drupal/docker-compose.vsd.yml \
# up -d
