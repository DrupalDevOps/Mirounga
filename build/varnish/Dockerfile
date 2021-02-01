FROM alexanderallen/nobody:latest
LABEL maintainer="14018885+AlexanderAllen@users.noreply.github.com"

ARG VARNISH_ADMIN_LISTEN_PORT=6082
ARG VARNISH_CACHE_SIZE=32M
ARG VARNISH_BACKEND=nginx:8080

RUN \
  mkdir -p /opt/varnish \
  && apk add --no-cache varnish \
  && chown -R nobody:nobody /var/lib/varnish /opt/varnish

COPY default.vcl /opt/varnish/default.vcl

EXPOSE ${VARNISH_LISTEN} ${VARNISH_ADMIN_LISTEN_PORT}

STOPSIGNAL SIGTERM

ENTRYPOINT [ "su-exec", "nobody", "/usr/sbin/varnishd" ]
CMD -F -a 0.0.0.0:80 -s malloc,${VARNISH_CACHE_SIZE} -b ${VARNISH_BACKEND} -p default_ttl=3600 -p default_grace=3600
