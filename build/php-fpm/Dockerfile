# From https://hub.docker.com/_/php/.

FROM alpine:3.11

LABEL InitialReleaseDate="First released on Oct 14, 2016."
LABEL RELEASEDATE="20191222"
LABEL MAINTAINER="14018885+AlexanderAllen@users.noreply.github.com"

# PHP Major Version as available on pkgs.alpinelinux.org
# Initial release was $PHP_VERSION (5.6.36).
ARG PHP_VERSION='php7'
ARG XDEBUG_RELEASE='2.9.0'

ENV \
    PHP_INI_MAX_EXECUTION_TIME=30 \
    PHP_INI_MEM_LIMIT=256M \
    PHP_FPM_ERRLOG=/var/log/php-fpm.log \
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

RUN \
    cd /tmp \
    && apk add --no-cache --virtual .build-deps $BUILD_DEPS \
    && apk add --no-cache \
        ${PHP_VERSION}-common \
       # ${PHP_VERSION}-cli \ # not found
        ${PHP_VERSION}-curl \
        ${PHP_VERSION}-ctype \
        ${PHP_VERSION}-dom \
        ${PHP_VERSION}-fpm \
        ${PHP_VERSION}-gd \
        ${PHP_VERSION}-intl \
        ${PHP_VERSION}-pecl-imagick \
        ${PHP_VERSION}-imap \
        ${PHP_VERSION}-iconv \
        ${PHP_VERSION}-json \
        ${PHP_VERSION}-mysqli \
        ${PHP_VERSION}-pecl-mcrypt \
        ${PHP_VERSION}-pecl-memcached \
        ${PHP_VERSION}-pear \
        ${PHP_VERSION}-phpdbg \
        ${PHP_VERSION}-pspell \
        ${PHP_VERSION}-phar \
        ${PHP_VERSION}-pcntl \
        ${PHP_VERSION}-posix \
        ${PHP_VERSION}-pdo \
        ${PHP_VERSION}-pdo_mysql \
        ${PHP_VERSION}-openssl \
        ${PHP_VERSION}-opcache \
        ${PHP_VERSION}-xml \
        ${PHP_VERSION}-xmlrpc \
        ${PHP_VERSION}-xmlreader \
        ${PHP_VERSION}-xmlwriter \
        ${PHP_VERSION}-simplexml \
        ${PHP_VERSION}-xsl \
        ${PHP_VERSION}-pecl-xhprof \
        ${PHP_VERSION}-pecl-xhprof-assets \
        zlib \
        supervisor \
    # && apk add --no-cache --virtual .xhprof-deps \
    #     graphviz \
    #     fontconfig \
    #     font-adobe-100dpi \
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
    # && git clone https://github.com/phacility/xhprof.git \
    # && ( \
    #     cd xhprof/extension \
    #     && phpize \
    #     && ./configure \
    #     && make \
    #     && make install \
    # ) \
    # && rm -rf xhprof/extension \
    # && mv xhprof ${XHPROF_PATH} \
    # && mkdir -m +rw ${XHPROF_OUTPUT_DIR} &> /dev/null \
    && apk del .build-deps \
    && ln -sf /dev/stdout ${XDEBUG_REMOTE_LOG} \
    && ln -sf /dev/stdout ${PHP_FPM_ERRLOG}

# Configure PHP-FPM.
COPY php-fpm.conf /etc/${PHP_VERSION}/php-fpm.conf

# Configure PHP.
COPY php.ini /etc/${PHP_VERSION}/conf.d/10-custom.ini

# Configure XDebug.
COPY xdebug.ini /etc/${PHP_VERSION}/conf.d/20-xdebug.ini

# Configure XHProf.
COPY xhprof.ini /etc/${PHP_VERSION}/conf.d/20-xhprof.ini

# Configure Supervisor.
COPY supervisord.conf /etc/supervisor.d/php-fpm.ini

ENTRYPOINT ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
