FROM alpine:3.11

# Maintainer is deprecated, use LABEL.
# MAINTAINER Johan Bergström <bugs@bergstroem.nu>

# System user used to run the MySQL server.
ENV DAEMON_USER=mysql
# Username used to log in to the database using MySQL client.
ARG CLIENT_USER=docker

# Build-time metadata as defined at http://label-schema.org
# DEPRECATED IN FAVOUR OF OCI IMAGE SPEC !!!
# https://github.com/opencontainers/image-spec


# https://dev.mysql.com/doc/refman/5.6/en/mysql-install-db.html
# As of MySQL 5.6.8, mysql_install_db is a Perl script and can be used on any system with Perl installed.
# Before 5.6.8, it is a shell script and is available only on Unix platforms.
# Therefore: to reduce image size, run installation script inside the build, then remove Perl when install is complete.

RUN \
  export sharedir=/usr/share/mariadb \
  # Need bash for evaluating path name expansions.
  && apk add --no-cache mariadb=10.4.10-r0 bash su-exec \
  #
  # Cleanup after install.
  #
  && rm -rf /etc/my.cnf.d/* /etc/my.cnf.apk-new /usr/data/test/db.opt /usr/share/terminfo /usr/mysql-test /usr/share/perl5 /usr/lib/perl5 \
  # /usr/bin @ 97MB: No need for advanced backups, compression (mbstream)
  && /bin/bash -c 'rm -rf /usr/bin/{mysql,mariabackup,mbstream,perror,pod*,resolveip,perl*,my_safe_process}' \
  && /bin/bash -c 'rm -rf /usr/bin/mysql{admin,check,dump,import,show,test*,access,dumpslow,hotcopy,_isntall_db}' \
  && /bin/bash -c 'rm -rf ${sharedir}/{README*,COPYING*,*.cnf}' \
  && /bin/bash -c 'rm -rf ${sharedir}/{binary-configure,mysqld_multi.server,mysql-log-rotate,mysql.server,install_spider.sql}' \
  && find ${sharedir} -mindepth 1 -type d ! -name 'charsets' ! -name 'english' -print0 | xargs -0 rm -rf \
  && touch ${sharedir}/mysql_system_tables_data.sql \
  && mkdir -p /run/mysqld \
  # Grant permissions to container user, container won't be running as root.
  && chown --recursive ${DAEMON_USER}:${DAEMON_USER} /etc/my.cnf.d/ /run/mysqld ${sharedir}/mysql_system_tables_data.sql /usr/lib/mariadb \
  && for p in aria* myisam* mysqld_* innochecksum \
              mysqlslap replace wsrep* msql2mysql sst_dump \
              resolve_stack_dump mysqlbinlog myrocks_hotbackup test-connect-t \
              $(cd /usr/bin; ls mysql_*| grep -v mysql_install_db); \
              do eval rm /usr/bin/${p}; done \
  # Not using pam for authentication.
  && /bin/bash -c 'rm -rf /lib/{libpam*,security}' \
  # APK cleanup, remove changes in new layer ~1.3MB.
  && apk del -q --no-cache --purge bash
  # Compression, PCRE, libstdc++, libxml, ssl, tls.
  # Apparently all these new libs are installed AND needed by the new mariadb version.
  #   && rm -rf /usr/lib/libxml* /usr/lib/libpcre* /usr/lib/libstd* /usr/lib/libpanel* /usr/lib/libncurses* /usr/lib/libme* /usr/lib/liblzma* \
  #     /usr/lib/libgcc* /usr/lib/libform* /usr/lib/libbz* /usr/lib/libaio* /usr/lib/libz*

COPY scripts/install /opt/docker/install
COPY my.cnf /tmp/
COPY scripts/entrypoint /opt/docker/entrypoint

# This is not super helpful; mysqld might be running but not accepting connections.
# Since we have no clients, we can't really connect to it and check.
#
# Below is in my opinion better than no health check.
HEALTHCHECK --start-period=3s CMD pgrep mysqld

VOLUME ["/var/lib/mysql"]

EXPOSE 3306
ENTRYPOINT [ "/opt/docker/entrypoint" ]
