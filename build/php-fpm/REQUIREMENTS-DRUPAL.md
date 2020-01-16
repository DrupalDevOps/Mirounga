DRUPAL REQUIREMENTS FOR PHP

This is a pseudo-Dockerfile list of Drupal requirements, with links to documentation.

    # For OFFICIAL Drupal 8 requirements see
    # https://www.drupal.org/docs/8/system-requirements/php-requirements
    #
    # For OFFICIAL list of required extensions, see
    # https://git.drupalcode.org/project/drupal/blob/8.7.x/core/composer.json
    #
    # "ext-date": "*",
    # "ext-dom": "*",
    # "ext-filter": "*",
    # "ext-gd": "*",
    # "ext-hash": "*",
    # "ext-json": "*",
    # "ext-pcre": "*",
    # "ext-PDO": "*",
    # "ext-session": "*",
    # "ext-SimpleXML": "*",
    # "ext-SPL": "*",
    # "ext-tokenizer": "*",
    # "ext-xml": "*",


    RUN \
        cd /tmp \
        && apk add --no-cache \
            ${PHP_VERSION} \
          # ${PHP_VERSION}-cli \ # not found
            ${PHP_VERSION}-curl \
            #
            ${PHP_VERSION}-fpm \
            #
            # Required by Composer and Drupal installer.
            ${PHP_VERSION}-mbstring \
            #
            # The Drupal installer complains when you don't have opcache enabled.
            ${PHP_VERSION}-opcache \
            #
            # Required in Drupal core composer.json.
            ${PHP_VERSION}-dom \
            ${PHP_VERSION}-gd \
            ${PHP_VERSION}-json \
            ${PHP_VERSION}-pdo \
            ${PHP_VERSION}-pdo_mysql \
            ${PHP_VERSION}-session \
            ${PHP_VERSION}-simplexml \
            ${PHP_VERSION}-tokenizer \
            ${PHP_VERSION}-xml \
            #
            # Would allow to send emails. Not required.
            # https://www.php.net/manual/en/intro.imap.php
            # ${PHP_VERSION}-imap \
            #
            # https://www.php.net/manual/en/function.iconv.php
            # iconv — Convert string to requested character encoding
            # ${PHP_VERSION}-iconv \
            #
            # Should be baked in with PHP core already - not needed.
            # https://www.drupal.org/docs/8/system-requirements/php-requirements#json
            # ${PHP_VERSION}-json \
            #
            # ${PHP_VERSION}-mysqli \
            # ${PHP_VERSION}-pecl-mcrypt \
            # ${PHP_VERSION}-pecl-memcached \
            # ${PHP_VERSION}-pear \
            #
            # # PHP DBG is a command line debugger, and it's a 40MB extension.
            # If you really want it, consider adding to the dev image.
            # # https://pkgs.alpinelinux.org/package/edge/community/x86_64/php7-dbg
            # # ${PHP_VERSION}-phpdbg \
            #
            # Spelling - we dont need this.
            # https://www.php.net/manual/en/intro.pspell.php
            # ${PHP_VERSION}-pspell \
            # ${PHP_VERSION}-phar \
            # ${PHP_VERSION}-pcntl \
            # ${PHP_VERSION}-posix \
            #
            # https://www.drupal.org/docs/8/system-requirements/php-requirements#database
            # The PHP Data Objects (PDO) extension must be activated for Drupal 8 to install and run correctly.
            # ${PHP_VERSION}-pdo \
            # ${PHP_VERSION}-pdo_mysql \
            #
            # Recommended but apparently not required. Allows Drupal to make https requests.
            # https://www.drupal.org/docs/8/system-requirements/php-requirements#openssl
            # ${PHP_VERSION}-openssl \
            #
            # https://www.drupal.org/docs/8/system-requirements/php-requirements#xml
            # Required by xsl, xmlreader
            # Enabling the XML extension also enables PHP DOM. DOM is now a systems requirement.
            # ${PHP_VERSION}-dom \
            # #
            # ${PHP_VERSION}-xml \
            # ${PHP_VERSION}-xmlrpc \
            # ${PHP_VERSION}-xmlreader \
            # ${PHP_VERSION}-xmlwriter \
            # ${PHP_VERSION}-simplexml \
            # ${PHP_VERSION}-xsl \
            zlib \
            su-exec \
        && ln -sf /dev/stdout ${PHP_FPM_ERRLOG} \
        && ln -sf /dev/stdout ${PHP_FPM_SLOWLOG}
