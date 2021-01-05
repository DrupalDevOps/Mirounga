#!/bin/bash

# Bring down stack if it exists.
ENV=${ENVIRONMENT:-vsd}
echo "Stop Docker Compose ${ENV} environment."

docker-compose \
-f docker-compose.yml \
-f run/drupal/docker-compose.vsd.yml \
down

echo "Remove user bridge network."
docker network rm VSD
