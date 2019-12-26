FROM alexanderallen/openresty:latest

# Replace our custom Drupal vhost with one for XHProf.
COPY vhost.conf ${NGINX_PATH}/sites-enabled/vhost.conf

# Where to install XHProf.
ARG XHPROF_PATH="/usr/local/xhprof"

# These are the environment variables used by the Nginx virtual host.
ENV \
    NGINX_VHOST_NAME=xhprof \
    NGINX_WEB_ROOT="${XHPROF_PATH}/xhprof_html" \
    NGINX_HTTP_LISTEN=80

# Download XHProf project code.
# We need to point our vhost to XHProf's index.html, we do not need the PHP extension in this container.
RUN \
    cd /tmp \
    && apk add --no-cache --virtual .build-deps \
        git \
    && git clone https://github.com/phacility/xhprof.git \
    && rm -rf xhprof/extension \
    && mv xhprof ${XHPROF_PATH} \
    && apk del .build-deps
