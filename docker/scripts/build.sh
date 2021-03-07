#!/bin/bash

set +x

# Build singular service if specified in first argument.
# http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html
#
if [ $1 ]; then

  docker-compose -f ./build/${1}/docker-compose.yml build

else
  # Follow Alpine releases @ https://alpinelinux.org.
  export ALPINE_MAJOR=3
  export ALPINE_MINOR=12
  export ALPINE_PATCH=14

  # Specify --no-cache to bust cache.
  USE_CACHE=""

  # If there is any base image, build first.
  docker-compose -f ./build/nobody/docker-compose.yml build ${USE_CACHE} \
    --build-arg ALPINE_MAJOR=${ALPINE_MAJOR} \
    --build-arg ALPINE_MINOR=${ALPINE_MINOR} \
    --build-arg ALPINE_PATCH=${ALPINE_PATCH}
  docker tag alexanderallen/nobody alexanderallen/nobody:alpine-${ALPINE_MAJOR}.${ALPINE_MINOR}.${ALPINE_PATCH}

  docker-compose -f ./build/varnish/docker-compose.yml build ${USE_CACHE} \
  && docker-compose -f ./build/nginx/docker-compose.yml build ${USE_CACHE} \
  && docker-compose -f ./build/mariadb-alpine/docker-compose.yml build ${USE_CACHE} \
  && docker-compose -f ./build/php-fpm/docker-compose.yml build ${USE_CACHE}

  docker tag alexanderallen/php7-fpm.dev:alpine-${ALPINE_MAJOR}.${ALPINE_MINOR}.${ALPINE_PATCH} alexanderallen/php7-fpm.dev:latest

  docker-compose -f ./build/php-cli/docker-compose.yml build ${USE_CACHE}

  docker tag alexanderallen/varnish alexanderallen/varnish:6
  docker tag alexanderallen/varnish alexanderallen/varnish:alpine-${ALPINE_MAJOR}.${ALPINE_MINOR}.${ALPINE_PATCH}

  docker images | grep alexanderallen
fi

# && docker-compose -f ./build/xhprof-viewer/docker-compose.yml build \

# Cleanup <3
#
# Remove dangling/intermidiate images from build.
# https://docs.docker.com/config/pruning/

docker image prune --force
