FROM alpine:3.12 as prod
LABEL MAINTAINER="14018885+AlexanderAllen@users.noreply.github.com"

ARG NGINX_HTTP_LISTEN
STOPSIGNAL SIGTERM
EXPOSE ${NGINX_HTTP_LISTEN}

RUN \
  apk add --no-cache \
  npm \
  nodejs

RUN \
  apk add --no-cache  \
  nginx \
  su-exec

RUN apk add --no-cache supervisor

COPY --chown=nobody:nobody nginx.conf index.html /etc/nginx/

RUN \
  cd /tmp \
  && id nobody \
  && deluser nobody \
  && adduser --disabled-password --gecos 'Klaes Ashford' --uid 1000 nobody \
  && addgroup nobody tty \
  && groups nobody && id nobody \
  \
  # Create .pid directory accessible by non root.
  && mkdir /var/run/nginx \
  && chmod -R o+rwx /var/run/nginx /var/lib/nginx /var/log/nginx \
  && rm /etc/nginx/conf.d/default.conf

ENTRYPOINT [ "su-exec", "nobody", "/usr/sbin/nginx", "-g", "daemon off;" ]
