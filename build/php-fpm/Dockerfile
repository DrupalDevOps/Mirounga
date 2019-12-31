FROM alpine:3.11 AS core

LABEL InitialReleaseDate="First released on Oct 14, 2016."
LABEL RELEASEDATE="20191222"
LABEL MAINTAINER="14018885+AlexanderAllen@users.noreply.github.com"

# PHP Major Version as available on pkgs.alpinelinux.org
# Initial release was $PHP_VERSION (5.6.36).
ENV PHP_VERSION=php7

ENV \
    PHP_INI_MAX_EXECUTION_TIME=30 \
    PHP_INI_MEM_LIMIT=256M \
    PHP_FPM_ERRLOG=/var/log/php-fpm.log

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
        # php7 -> 4.6MB; /usr -> 11MB
        ${PHP_VERSION} \
       # ${PHP_VERSION}-cli \ # not found
        ${PHP_VERSION}-curl \
        #
        # https://pkgs.alpinelinux.org/package/edge/community/x86_64/php7-ctype
        # required by drupal7 package (not using that), php7-pecl-xhprof (maybe maybe not, can be moved to dev image)
        #${PHP_VERSION}-ctype \
        #
        # 16 MB. Alpine says 5MB installed size. I say it takes more.
        ${PHP_VERSION}-fpm \
        #
        # 23 MB. /usr/x11 1.3MB
        # https://www.drupal.org/docs/8/system-requirements/php-requirements#image
        # An image library for PHP such as the GD library is a required extension in Drupal 8, and is needed for image manipulation
        # ${PHP_VERSION}-gd \
        # ${PHP_VERSION}-pecl-imagick \
        #
        # ${PHP_VERSION}-intl \
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
        # ${PHP_VERSION}-opcache \
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
    && ln -sf /dev/stdout ${PHP_FPM_ERRLOG}

# Configure PHP-FPM.
COPY php-fpm.conf /etc/${PHP_VERSION}/php-fpm.conf

# Configure PHP.
COPY php.ini /etc/${PHP_VERSION}/conf.d/10-custom.ini

ENTRYPOINT ["su-exec", "nobody", "/usr/sbin/php-fpm7", "--nodaemonize", "--force-stderr"]


FROM core AS development

# Tidewall is a replacement for the original XHProf (outdated).
# https://github.com/tideways/php-xhprof-extension/releases
ARG XHPROF_RELEASE='v5.0.2'
ARG XDEBUG_RELEASE='2.9.0'

ENV \
    XDEBUG_REMOTE_ENABLE=1 \
    XDEBUG_CONNECT_BACK=1 \
    XDEBUG_REMOTE_HOST=10.254.254.254 \
    XDEBUG_REMOTE_PORT=9000 \
    XDEBUG_REMOTE_LOG=/tmp/xdebug.log \
    XDEBUG_IDE_KEY='PHPSTORM' \
    XDEBUG_FORCE_DISPLAY_ERRORS=1 \
    XDEBUG_SHOW_EXCEPTION_TRACE=0 \
    XDEBUG_SHOW_MEMDELTA=1 \
    XDEBUG_DEFAULT_ENABLE=1 \
    XHPROF_OUTPUT_DIR=/var/tmp/xhprof \
    XHPROF_PATH=/usr/local/xhprof

# Build dependencies.
ENV BUILD_DEPS \
        autoconf \
        file \
        g++ \
        gcc \
        libc-dev \
        make \
        pkgconf \
        re2c \
        git \
        ${PHP_VERSION}-dev

# DOG5992373

RUN \
    cd /tmp \
    && apk add --no-cache --virtual .build-deps $BUILD_DEPS \
    && apk add --no-cache \
        ${PHP_VERSION}-pecl-xhprof-assets \
    # && apk add --no-cache --virtual .xhprof-deps \
    #     graphviz \
    #     fontconfig \
    #     font-adobe-100dpi \
    #
    # Turn OFF git "advice.detachedHead" warning before,
    # reduces build verbosity when checking out tags.
    && git config --global advice.detachedHead false \
    #
    # Build fresh xdebug release for latest fixes and features.
    && git clone git://github.com/xdebug/xdebug.git \
    && ( \
        cd xdebug \
        && git checkout tags/${XDEBUG_RELEASE} \
        && phpize \
        && ./configure --enable-xdebug \
        && make \
        && cp modules/xdebug.so /usr/lib/${PHP_VERSION}/modules \
    ) \
    && rm -rf xdebug \
    #
    # Build fresh XHProf release.
    # Pre-built binary also available at https://pkgs.alpinelinux.org/packages?name=*tideways*&branch=edge.
    && git clone https://github.com/tideways/php-xhprof-extension.git \
    && ( \
        cd php-xhprof-extension \
        && git checkout tags/${XHPROF_RELEASE} \
        && phpize \
        && ./configure \
        && make \
        && make install \
        # && mv xhprof ${XHPROF_PATH} \
        && mkdir -m +rw ${XHPROF_OUTPUT_DIR} &> /dev/null \
    ) \
    && rm -rf php-xhprof-extension \
    && apk del .build-deps \
    && ln -sf /dev/stdout ${XDEBUG_REMOTE_LOG}

# Configure XDebug.
COPY xdebug.ini /etc/${PHP_VERSION}/conf.d/20-xdebug.ini

# Configure XHProf.
COPY xhprof.ini /etc/${PHP_VERSION}/conf.d/20-xhprof.ini
