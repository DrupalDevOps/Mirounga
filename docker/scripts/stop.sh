#!/bin/bash

# Bring down stack if it exists.
ENV=${ENVIRONMENT:-prod}
echo "Stopping Docker Compose ${ENV} environment."

docker-compose \
-f docker-compose.yml \
-f run/drupal/docker-compose.${ENV}.yml \
-f run/drush/docker-compose.${ENV}.yml \
down --remove-orphans
