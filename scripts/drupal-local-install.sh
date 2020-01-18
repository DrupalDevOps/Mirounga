#!/bin/bash

# Abort if any of the steps fails.
# set -e

DATABASE_NAME="localenv"
DATABASE_USER="docker"
DATABASE_HOST="mysql"

# Where is the project mounted at: could be either named volume or host mount.
WORKDIR="/app"

# Install MySQL client at runtime to avoid bloating the Docker image.
# This step must run as ROOT in order to install the APK mysql client.
# Re-create database.
echo ""
echo "MySQL: Recreate database ${DATABASE_NAME}"
RECREATE_DB="apk add --no-cache mariadb-client && mysql --verbose -u ${DATABASE_USER} -h ${DATABASE_HOST} -e 'DROP DATABASE IF EXISTS ${DATABASE_NAME}; CREATE DATABASE ${DATABASE_NAME};'"
docker-compose \
  -f docker-compose.yml \
  -f run/drupal/docker-compose.dev.yml \
  run --rm --user=root \
  --entrypoint bash \
  drush -c "${RECREATE_DB}"


echo ""
echo "Nuke work directory prior running Composer"
rm -rf ./app/*
rm -rf ./app/.* 2> /dev/null


# Todo: don't re-run composer if it's already project alraedy present?
echo ""
echo "Composer: create Drupal project"
docker-compose \
  -f docker-compose.yml \
  -f run/drupal/docker-compose.dev.yml \
  run --rm --user=nobody --workdir="${WORKDIR}" \
  --entrypoint bash \
  drush -c "composer -vvv --no-cache create-project --prefer-dist --no-dev drupal/recommended-project ."


echo ""
echo "Drush: create Drupal project"
DRUSH_SI="drush \
  --verbose \
  site-install \
  standard install_configure_form.enable_update_status_emails=NULL \
  --site-name=${DATABASE_NAME} \
  --account-pass=admin \
  --account-name=admin \
  --locale=en \
  --account-mail="admin@example.com" \
  --db-su=${DATABASE_USER} \
  --db-url=mysql://${DATABASE_USER}@${DATABASE_HOST}:3306/${DATABASE_NAME} \
  --yes"

docker-compose \
  -f docker-compose.yml \
  -f run/drupal/docker-compose.dev.yml \
  run --rm --user=nobody --workdir="${WORKDIR}" \
  --entrypoint bash \
  drush -c "${DRUSH_SI}"
