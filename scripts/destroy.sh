#!/bin/bash

# Bring down stack if it exists.
ENV=${ENVIRONMENT:-prod}
echo "Stopping and removing Docker Compose ${ENV} environment."

# Destroy volumes.
docker-compose \
-f docker-compose.yml \
-f run/drupal/docker-compose.${ENV}.yml \
down -v

# Cleanup while we're at it.
docker system prune
