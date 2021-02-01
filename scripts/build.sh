#!/bin/bash

set +x

# Build singular service if specified in first argument.
# http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html
#
if [ $1 ]; then

  docker-compose -f ./build/${1}/docker-compose.yml build

else
  ALPINE_MAJOR=3
  ALPINE_MINOR=12

  # If there is any base image, build first.
  docker-compose -f ./build/nobody/docker-compose.yml build \
    --no-cache --build-arg ALPINE_MAJOR=$ALPINE_MAJOR --build-arg ALPINE_MINOR=$ALPINE_MINOR
  docker tag alexanderallen/nobody alexanderallen/nobody:alpine-$ALPINE_MAJOR.$ALPINE_MINOR

  docker-compose -f ./build/varnish/docker-compose.yml build \
  && docker-compose -f ./build/nginx/docker-compose.yml build \
  && docker-compose -f ./build/mariadb-alpine/docker-compose.yml build \
  && docker-compose -f ./build/php-fpm/docker-compose.yml build \
  && docker-compose -f ./build/php-cli/docker-compose.yml build

  docker images | grep alexanderallen
fi

# && docker-compose -f ./build/xhprof-viewer/docker-compose.yml build \

# Cleanup <3
#
# Remove dangling/intermidiate images from build.
# https://docs.docker.com/config/pruning/

docker image prune --force
