FROM nginx:1.17-alpine AS core
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

# Copy dynamic vhost definition into container.
# Use one container for each application, using environment variables passed to the run command.
COPY vhost.conf /etc/nginx/sites-enabled/vhost.conf

# RUN \
#   cd /tmp \
#   && apk add --no-cache \
#   su-exec \
#   nginx \
#   net-tools
  # or openresty

# ENTRYPOINT ["su-exec", "root", "/usr/sbin/nginx"]

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
