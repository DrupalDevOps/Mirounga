#!/bin/bash

set +x

docker-compose -f ./build/nginx/docker-compose.yml build \
&& docker-compose -f ./build/mariadb-alpine/docker-compose.yml build \
&& docker-compose -f ./build/php-fpm/docker-compose.yml build \
&& docker-compose -f ./build/php-cli/docker-compose.yml build \
&& docker-compose -f ./build/drupal/docker-compose.yml build
