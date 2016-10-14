# From https://hub.docker.com/_/php/.

FROM alpine:3.4

MAINTAINER Richard Alexander Allen <richard.alexander.allen@gmail.com>

ARG XDEBUG_RELEASE='XDEBUG_2_4_1'

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
    XDEBUG_SHOW_EXCEPTION_TRACE=1 \
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
        php5-dev

RUN \
    cd /tmp \
    && apk add --no-cache --virtual .build-deps $BUILD_DEPS \
    && apk add --no-cache \
        php5-common \
        php5-cli \
        php5-curl \
        php5-ctype \
        php5-dom \
        php5-fpm \
        php5-gd \
        php5-intl \
        php5-imagick \
        php5-imap \
        php5-iconv \
        php5-json \
        php5-mysql \
        php5-mcrypt \
        php5-memcache \
        php5-pear \
        php5-phpdbg \
        php5-pspell \
        php5-phar \
        php5-pspell \
        php5-pcntl \
        php5-posix \
        php5-pdo \
        php5-pdo_mysql \
        php5-openssl \
        php5-opcache \
        php5-xml \
        php5-xmlrpc \
        php5-xmlreader \
        php5-xsl \
        php5-zlib \
        supervisor \
    && apk add --no-cache --virtual .xhprof-deps \
        graphviz \
        fontconfig \
        font-adobe-100dpi \
    && git clone git://github.com/xdebug/xdebug.git \
    && ( \
        cd xdebug \
        && git checkout tags/$XDEBUG_RELEASE \
        && phpize \
        && ./configure --enable-xdebug \
        && make \
        && cp modules/xdebug.so /usr/lib/php5/modules \
    ) \
    && rm -rf xdebug \
    && git clone https://github.com/phacility/xhprof.git \
    && ( \
        cd xhprof/extension \
        && phpize \
        && ./configure \
        && make \
        && make install \
    ) \
    && rm -rf xhprof/extension \
    && mv xhprof ${XHPROF_PATH} \
    && mkdir -m +rw ${XHPROF_OUTPUT_DIR} &> /dev/null \
    && apk del .build-deps \
    && ln -sf /dev/stdout ${XDEBUG_REMOTE_LOG} \
    && ln -sf /dev/stdout ${PHP_FPM_ERRLOG}

# Configure PHP-FPM.
COPY php-fpm.conf /etc/php5/php-fpm.conf

# Configure PHP.
COPY php.ini /etc/php5/conf.d/10-custom.ini

# Configure XDebug.
COPY xdebug.ini /etc/php5/conf.d/20-xdebug.ini

# Configure XHProf.
COPY xhprof.ini /etc/php5/conf.d/20-xhprof.ini

# Configure Supervisor.
COPY supervisord.conf /etc/supervisor.d/php-fpm.ini

ENTRYPOINT ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
