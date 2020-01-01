#!/bin/bash

./start.sh

docker-compose -f run/drush/docker-compose.yml run --rm drush
