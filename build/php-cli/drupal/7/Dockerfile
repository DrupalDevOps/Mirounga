#
# Build stage optimized with Composer packages for Drupal development.
#
FROM alexanderallen/php-cli.core:latest

RUN \
    cd /tmp \
    && apk add --no-cache \
      # REQ: Composer squizlabs/php_codesniffer 2.7.0 requires ext-tokenizer
      ${PHP_VERSION}-tokenizer \
      # REQ: Composer drupal/coder 8.3.7 requires ext-mbstring
      ${PHP_VERSION}-mbstring

# Provide optional composer example to install.
COPY composer.json ${COMPOSER_HOME}/composer.json

# Install default CLI tools.
RUN composer global -vvv install

# Download additional Drupal Security standards files.
RUN git clone --branch master http://git.drupal.org/sandbox/coltrane/1921926.git sandbox_1921926 \
  && mv sandbox_1921926/DrupalSecure ${COMPOSER_HOME}/vendor/drupal/coder/coder_sniffer/DrupalSecure \
  && rm -rf sandbox_1921926

# Inform PHP Code Snifer (phpcs) about Drupal coding standards sniff files.
RUN phpcs --config-set installed_paths ${COMPOSER_HOME}/vendor/drupal/coder/coder_sniffer

# Provide a dynamic entrypoint into the container.
COPY entrypoint.sh /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
