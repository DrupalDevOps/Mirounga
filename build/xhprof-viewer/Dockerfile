FROM alexanderallen/nginx:1.17-alpine

RUN apk add --no-cache php7-pecl-xhprof-assets

COPY vhost.conf /etc/nginx/conf.d/default.conf
