#!/bin/bash

export XDEBUG_REMOTE_HOST=`ip addr show eth0 | grep -oE '\d+(\.\d+){3}' | head -n 1`
echo "XDebug will contact IDE at ${XDEBUG_REMOTE_HOST}"

# export PROJECT_ROOT="/home/wsl/drupal-8.8.1"
export PROJECT_ROOT="/home/wsl/hello-php"

# Location to mount into the containers (php-fpm, nginx, drush).
export PROJECT_DEST="/sites"

# Drush script using production configuration.

ENV=${ENVIRONMENT:-prod}
echo "Running Drush for ${ENV} environment."

# Start local stack on which to run Drush on.
./scripts/start.sh

# Merge Drush compose onto existing stack definition.
# Paths are relative to project root, when invoking script from project root.
docker-compose \
-f docker-compose.yml \
-f run/drupal/docker-compose.${ENV}.yml \
-f run/drush/docker-compose.${ENV}.yml \
run --rm drush "$@"
# run --rm --user=root drush "$@"
