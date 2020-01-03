FROM alexanderallen/php7-fpm.core:alpine-3.11 as core

ENV \
  SSH_PRIVATE_KEY="/root/.ssh/id_rsa" \
  LANG="en_US.UTF-8" \
  LC_ALL="en_US.UTF-8" \
  LANGUAGE="en_US.UTF-8" \
  TERM="xterm" \
  # Register the COMPOSER_HOME environment variable.
  COMPOSER_HOME=/composer \
  # Add global binary directory to PATH.
  PATH=/composer/vendor/bin:$PATH \
  # Allow Composer to be run as root.
  COMPOSER_ALLOW_SUPERUSER=1

RUN \
  cd /tmp \
  && apk add --no-cache \
    php7-phar \
    bash \
    git \
    # Used for Composer install.
    curl

# Setup the Composer installer.
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
  && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --snapshot && rm -rf /tmp/composer-setup.php

# Configure Z shell.
# COPY common/.zshrc /root/.zshrc

# Since the more efficient method of agent-forwarding is not supported on all
# Docker environments, start an ssh-agent and add a key.
# Required for Composer repos that need SSH instead of HTTPS.
# COPY common/.bashrc /root/.bashrc

# Where all of our codebase is mounted to.
WORKDIR /www

# Core image CLI entrypoint.
# ENTRYPOINT ["/bin/zsh", "--interactive"]
ENTRYPOINT ["/bin/sh", "--interactive"]


#
# Build stage optimized with Composer packages for Drupal development.
#
FROM core as drush9

# Specifies which composer.json file to use for build.
ARG DRUSH_VERSION
RUN \
  cd /tmp \
  && apk add --no-cache \
    # Currently mounting keys to containers due to lack of agent socket support.
    openssh-client

# Provide optional composer example to install.
COPY drush/${DRUSH_VERSION}/composer.json ${COMPOSER_HOME}/composer.json

# Install default CLI tools.
RUN composer global -vvv \
    --no-cache \
    install \
    --no-dev \
    # Good for production or when shipping code inside containers, since code is not expected to change.
    --optimize-autoloader

# Configure Drush 9 and above. Can be done by drush core:init instead.
# COPY common/drush.yml /root/.drush/drush.yml

# Provide a dynamic entrypoint into the container.
COPY common/entrypoint.sh /root/entrypoint.sh

ENTRYPOINT ["/bin/bash"]

# SSH Agent setup.
COPY common/.bashrc /root/.bashrc


FROM drush9 as qa-tools
RUN \
  cd /tmp \
  && apk add --no-cache \
    # REQ: Composer squizlabs/php_codesniffer 2.7.0 requires ext-tokenizer
    ${PHP_VERSION}-tokenizer

# Inform PHP Code Snifer (phpcs) about Drupal coding standards sniff files.
RUN phpcs --config-set installed_paths ${COMPOSER_HOME}/vendor/drupal/coder/coder_sniffer


FROM drush9 as cli-tools

RUN \
  cd /tmp \
  && apk add --no-cache \
  php7-phar \
  bash \
  git \
  mysql-client \
  tar \
  tree \
  tmux \
  vim \
  zsh \
  && apk add --no-cache --virtual .networking \
  curl \
  net-tools \
  nmap \
  openssh-client \
  wget \
  && git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
