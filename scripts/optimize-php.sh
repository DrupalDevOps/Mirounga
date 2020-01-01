#!/bin/sh

# Rebuild image - core language target.
docker-compose -f build/php-fpm/docker-compose.yml build php-fpm.core

docker-compose -f build/php-fpm/docker-compose.yml build php-fpm.dev

# Inspect buidl artifact.
docker run --rm -it \
-v /var/run/docker.sock:/var/run/docker.sock \
wagoodman/dive:latest alexanderallen/php7-fpm.core:alpine-3.11

docker run --rm -it \
-v /var/run/docker.sock:/var/run/docker.sock \
wagoodman/dive:latest alexanderallen/php7-fpm.dev:alpine-3.11


# https://nickjanetakis.com/blog/docker-tip-31-how-to-remove-dangling-docker-images
# Legacy, still works.
# docker rmi -f $(docker images -f "dangling=true" -q)

# Remove dangling images, all stopped containers, all networks not used by at least 1 container, all dangling images and build caches.
docker system prune --force

# docker run --rm -it \
# -v /var/run/docker.sock:/var/run/docker.sock \
# wagoodman/dive:latest kreait/php:7.1
