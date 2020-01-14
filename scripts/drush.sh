#!/bin/bash

# Drush script using production configuration.

# Start local stack on which to run Drush on.
./scripts/start.sh

# Merge Drush compose onto existing stack definition.
# Paths are relative to project root, when invoking script from project root.
docker-compose \
-f docker-compose.yml \
-f run/drupal/docker-compose.prod.yml \
-f run/drush/docker-compose.yml \
run --rm drush
