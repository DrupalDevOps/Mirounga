FROM alexanderallen/php7-fpm.dev:alpine-3.11 as composer-prod
# Build from dev in order to get xdebug.
# FROM alexanderallen/php7-fpm.prod:alpine-3.11 as composer-prod

ARG DOCKER_USER=nobody
ARG DRUSH_TAG

ENV \
  DOCKER_USER=${DOCKER_USER} \
  # Used for global composer commands.
  COMPOSER_HOME=/opt/composer  \
  LANG="en_US.UTF-8" \
  LC_ALL="en_US.UTF-8" \
  LANGUAGE="en_US.UTF-8" \
  TERM="xterm"

# Add composer binary directory to PATH.
ENV PATH=${COMPOSER_HOME}/vendor/bin:$PATH

RUN \
  cd /tmp \
  && apk add --no-cache \
    php7-phar \
    # Required by Drush 9.7.2.
    php7-posix \
    bash \
    git \
    mariadb-backup \
    mariadb-client \
    # Used for Composer install.
    curl

# Install Composer.
RUN \
  mkdir -p ${COMPOSER_HOME} \
  && curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
  && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --snapshot && rm -rf /tmp/composer-setup.php

RUN chown -R ${DOCKER_USER}:${DOCKER_USER} ${COMPOSER_HOME}

ENTRYPOINT ["/bin/bash"]



# Legacy platform (Drupal 7) target.
FROM composer-prod as drush7-prod
RUN \
  cd /opt \
  && git clone https://github.com/drush-ops/drush.git drush7
RUN \
  cd /opt/drush7 \
  && git branch --show-current \
  && echo "switching to branch/tag" \
  && git checkout 7.4.0 \
  && git branch --show-current \
  && composer install \
  && ln -s /opt/drush7/drush /usr/bin/drush \
  && /usr/bin/drush --version


#
# Build stage optimized with Composer packages for Drupal development.
#
FROM composer-prod as drush9-prod

# Specifies which composer.json file to use for build.
ARG DRUSH_VERSION

# Currently mounting keys to containers due to lack of agent socket support.
RUN apk add --no-cache openssh-client

# Composer manifest for global Drush install.
COPY drush/${DRUSH_VERSION}/composer.json ${COMPOSER_HOME}/composer.json

# Install Drupal console (separate from Drush).
#
# https://drupalconsole.com/docs/en/getting/launcher
# You must execute the launcher within a drupal site directory or use --root=/path/to/drupal8.dev
# to specify your drupal site path.
#
RUN curl https://drupalconsole.com/installer -L -o drupal.phar \
  && mv drupal.phar /opt/drupal \
  && chmod +x /opt/drupal \
  && chown -R ${DOCKER_USER}:${DOCKER_USER} /opt/drupal /opt

# Switch to non-root user before running drush commands.
USER ${DOCKER_USER}

# Install drush globally and anything else defined in the composer manifest.
RUN composer global -vvv \
    --no-cache \
    install \
    --no-dev \
    # Good for production or when shipping code inside containers, since code is not expected to change.
    --optimize-autoloader

# Configure Drush 9 and above. Can be done by drush core:init instead.
# COPY common/drush.yml /root/.drush/drush.yml

# Starts SSH agent.
#COPY common/.bashrc /home/${DOCKER_USER}/.bashrc



FROM drush9-prod as drush9-dev
RUN \
  cd /tmp \
  apk add --no-cache \
  ${PHP_VERSION}-pecl-xdebug \
  ${PHP_VERSION}-pecl-xhprof-assets \
  ${PHP_VERSION}-tideways_xhprof








#########################################################
# Targets below this line not yet built or implemented. #
#########################################################

# FROM drush9 as qa-tools
# RUN \
#   cd /tmp \
#   && apk add --no-cache \
#     # REQ: Composer squizlabs/php_codesniffer 2.7.0 requires ext-tokenizer
#     ${PHP_VERSION}-tokenizer

# # Inform PHP Code Snifer (phpcs) about Drupal coding standards sniff files.
# RUN phpcs --config-set installed_paths ${COMPOSER_HOME}/vendor/drupal/coder/coder_sniffer
