FROM alexanderallen/php-fpm.dev:latest as core

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

# Setup the Composer installer.
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
  && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --snapshot && rm -rf /tmp/composer-setup.php

# Configure Z shell.
COPY .zshrc /root/.zshrc

# Since the more efficient method of agent-forwarding is not supported on all
# Docker environments, start an ssh-agent and add a key.
# Required for Composer repos that need SSH instead of HTTPS.
COPY .bashrc /root/.bashrc

# Where all of our codebase is mounted to.
WORKDIR /www

# Core image CLI entrypoint.
ENTRYPOINT ["/bin/zsh", "--interactive"]

#
# Build stage optimized with Composer packages for Drupal development.
#
FROM core as drupal7

# Provide optional composer example to install.
COPY composer.json ${COMPOSER_HOME}/composer.json

# Install default CLI tools.
RUN composer global install

# Download additional Drupal Security standards files.
RUN git clone --branch master http://git.drupal.org/sandbox/coltrane/1921926.git sandbox_1921926 \
    && mv sandbox_1921926/DrupalSecure ${COMPOSER_HOME}/vendor/drupal/coder/coder_sniffer/DrupalSecure \
    && rm -rf sandbox_1921926

# Inform PHP Code Snifer (phpcs) about Drupal coding standards sniff files.
RUN phpcs --config-set installed_paths ${COMPOSER_HOME}/vendor/drupal/coder/coder_sniffer

# Provide a dynamic entrypoint into the container.
COPY entrypoint.sh /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
