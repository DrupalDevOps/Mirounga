FROM mariadb:10.1
LABEL maintainer="AlexanderAllen <14018885+AlexanderAllen@users.noreply.github.com>"

# Redirect database logs to Docker log collector.
USER mysql
RUN ln -sf -T /dev/stdout /var/log/mysql/mysql.log
RUN ln -sf -T /dev/stderr /var/log/mysql/error.log
RUN ln -sf -T /dev/stderr /var/log/mysql/slow.log
