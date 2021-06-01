FROM nginx:1.21-alpine AS core
# See https://github.com/nginxinc/docker-nginx/blob/a973c221f6cedede4dab3ab36d18240c4d3e3d74/mainline/alpine/Dockerfile'
# FROM alpine:3.11 AS core
LABEL maintainer="14018885+AlexanderAllen@users.noreply.github.com"

# ARG NGINX_WEB_ROOT
ARG NGINX_HTTP_LISTEN
ARG NGINX_PHPFPM_FASTCGI_PASS
ARG NGINX_LOGLEVEL

ENV NGINX_HTTP_LISTEN=$NGINX_HTTP_LISTEN \
    NGINX_PHPFPM_FASTCGI_PASS=$NGINX_PHPFPM_FASTCGI_PASS \
    NGINX_LOGLEVEL=$NGINX_LOGLEVEL

RUN rm /etc/nginx/conf.d/default.conf

# Copy dynamic vhost definition into container.
# Use one container for each application, using environment variables passed to the run command.

# VHost config file, included by main config (include /etc/nginx/conf.d/*.conf;).
COPY etc/nginx/conf.d/vhost.conf /etc/nginx/conf.d/default.conf

# Main config file.
COPY etc/nginx/nginx.conf /etc/nginx/nginx.conf

# Requires NJS 0.4.0+, included with nginx:1.19-alpine,
COPY etc/nginx/http.js /etc/nginx/http.js

ENV NGINX_HTTP_LISTEN 8080

RUN \
  cd /tmp \
  && apk add --no-cache su-exec \
  # Create .pid directory accessible by non root.
  && mkdir /var/run/nginx \
  && chmod -R o+rwx /var/run/nginx /var/cache/nginx \
  #
  # Reset anonymous user nobody to uid/gid 1000.
  && id nobody \
  && deluser nobody \
  && adduser --disabled-password --gecos 'Camina Drummer' --uid 1000 nobody \
  # Add nobody user to group tty, allowing php-fpm to log into /dev/std[out|err] as non-root.
  && addgroup nobody tty \
  # Confirm new uid/gid is 1000.
  && groups nobody && id nobody

EXPOSE ${NGINX_HTTP_LISTEN}

STOPSIGNAL SIGTERM

ENTRYPOINT [ "su-exec", "nobody", "/usr/sbin/nginx", "-g", "daemon off;" ]

FROM core as ssl

RUN \
  apk add --no-cache certbot certbot-nginx
