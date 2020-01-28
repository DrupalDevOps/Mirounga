#!/bin/bash

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
run --rm drush
