# Push images.
ALPINE_MAJOR=3
ALPINE_MINOR=13
ALPINE_PATCH=2

docker login

docker push alexanderallen/nginx:1.17-alpine

docker push alexanderallen/nobody:alpine-${ALPINE_MAJOR}.${ALPINE_MINOR}.${ALPINE_PATCH}
docker push alexanderallen/php7-fpm.prod:alpine-${ALPINE_MAJOR}.${ALPINE_MINOR}.${ALPINE_PATCH}
docker push alexanderallen/php7-fpm.dev:alpine-${ALPINE_MAJOR}.${ALPINE_MINOR}.${ALPINE_PATCH}
docker push alexanderallen/php7-cli.prod:alpine-${ALPINE_MAJOR}.${ALPINE_MINOR}.${ALPINE_PATCH}
docker push alexanderallen/php7-cli-drush9.prod:alpine-${ALPINE_MAJOR}.${ALPINE_MINOR}.${ALPINE_PATCH}
docker push alexanderallen/php7-cli-drush7.prod:alpine-${ALPINE_MAJOR}.${ALPINE_MINOR}.${ALPINE_PATCH}
docker push alexanderallen/varnish:alpine-${ALPINE_MAJOR}.${ALPINE_MINOR}.${ALPINE_PATCH}
docker push alexanderallen/mariadb-10:alpine-${ALPINE_MAJOR}.${ALPINE_MINOR}.${ALPINE_PATCH}
