FROM alpine:3.11 AS prod

LABEL InitialReleaseDate="First released on Oct 14, 2016."
LABEL RELEASEDATE="20191222"
LABEL MAINTAINER="14018885+AlexanderAllen@users.noreply.github.com"

# PHP Major Version as available on pkgs.alpinelinux.org
# Initial release was $PHP_VERSION (5.6.36).
ENV PHP_VERSION=php7

ENV \
    PHP_INI_MAX_EXECUTION_TIME=30 \
    PHP_INI_MEM_LIMIT=256M \
    PHP_FPM_ERRLOG=/dev/stderr \
    PHP_FPM_SLOWLOG=/dev/stderr \
    # Slowlog timeout value of 0 means 'off'.
    PHP_FPM_SLOWLOG_TIMEOUT=0 \
    PHP_FPM_LISTEN=127.0.0.1:9010 \
    # Use environment variables to speed up FPM optimization cycles.
    PHP_FPM_PM_MANAGER=dynamic \
    PHP_FPM_CHILDREN_MAX=5 \
    PHP_FPM_CHILDREN_START=2 \
    PHP_FPM_CHILDREN_SPARE_MIN=1 \
    PHP_FPM_CHILDREN_SPARE_MAX=3 \
    PHP_FPM_MAX_REQUESTS=0


# For OFFICIAL Drupal 8 requirements see
# https://www.drupal.org/docs/8/system-requirements/php-requirements
#
# For OFFICIAL list of required extensions, see
# https://git.drupalcode.org/project/drupal/blob/8.7.x/core/composer.json
#

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
        zlib \
        su-exec \
    # Cleanup defualt pool configuration.
    && rm /etc/php7/php-fpm.d/www.conf \
    # Allow php-fpm to log to /dev/std{out,err} as nobody.
    && addgroup nobody tty

# Configure PHP-FPM.
COPY php-fpm.conf /etc/${PHP_VERSION}/php-fpm.conf

# FPM pool configuration and any other customizations.
# Include defined in main configuration file.
COPY php-fpm.d/ /etc/php7/php-fpm.d/

# Configure PHP.
COPY php.ini /etc/${PHP_VERSION}/conf.d/10-custom.ini

ENTRYPOINT ["su-exec", "nobody", "/usr/sbin/php-fpm7", "--nodaemonize", "--force-stderr"]


FROM prod AS dev

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
        ${PHP_VERSION}-dev \
        # Microsoft Visual Studio Code Remote Development Requirements
        # https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack
        # https://code.visualstudio.com/docs/remote/linux#_remote-host-container-wsl-linux-prerequisites
        libstdc++ \
        libgcc

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
