FROM mariadb:10.1
MAINTAINER Richard Alexander Allen <richard.alexander.allen@gmail.com>

# Redirect database logs to Docker log collector.
USER mysql
RUN ln -sf -T /dev/stdout /var/log/mysql/mysql.log
RUN ln -sf -T /dev/stderr /var/log/mysql/error.log
RUN ln -sf -T /dev/stderr /var/log/mysql/slow.log
