FROM alexanderallen/nobody:alpine-3.12
LABEL maintainer="14018885+AlexanderAllen@users.noreply.github.com"

# su-exec nobody /usr/sbin/varnishd -s malloc,32M -a 0.0.0.0:80 -b nginx:8080
# -F -s malloc,32M -a :80 -b nginx:8080

# VARNISH_PARAMS="-p default_ttl=3600 -p default_grace=3600"
ARG VARNISH_LISTEN=80
ARG VARNISH_ADMIN_LISTEN_PORT=6082
ARG VARNISH_CACHE_SIZE=32M

RUN \
  mkdir -p /opt/varnish \
  && apk add --no-cache varnish \
  && chown -R nobody:nobody /var/lib/varnish /opt/varnish

COPY default.vcl /opt/varnish/default.vcl

EXPOSE ${VARNISH_LISTEN} ${VARNISH_ADMIN_LISTEN_PORT}

STOPSIGNAL SIGTERM

ENTRYPOINT [ "su-exec", "nobody", "/usr/sbin/varnishd" ]
CMD -F -s malloc,${VARNISH_CACHE_SIZE} -a 0.0.0.0:${VARNISH_LISTEN} -b nginx:8080
