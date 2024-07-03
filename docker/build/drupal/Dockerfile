#
# Production version Drupal image.
#
FROM alexanderallen/php7-cli-drush9.prod:alpine-3.11 as intermediate

ARG DOCKER_USER=nobody

# Volume by default creates dir as root if it doesn't exist.
# When running container as non root,
# create or chmod dir as desired user before declaring volume.
USER root

# Create intermediate build directory where to run create-project from.
RUN mkdir /source && chown ${DOCKER_USER}:${DOCKER_USER} /source

# Ensure any sources are downloaded as desired non-root user.
USER ${DOCKER_USER}
WORKDIR /source

# https://getcomposer.org/doc/03-cli.md#create-project
# https://www.drupal.org/docs/develop/using-composer/using-composer-to-install-drupal-and-manage-dependencies
# This downloads Drupal dependencies akin to composer install.
# Use --no-install flag to download manifest without installing dependencies.
RUN composer -vvv --no-cache create-project --prefer-dist --no-dev drupal/recommended-project .



# Extract source code from intermediate build step and copy to volume.
FROM alpine:3 as prod

COPY --from=intermediate /source /app

VOLUME [ "/app" ]
