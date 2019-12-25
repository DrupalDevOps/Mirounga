FROM alpine:3.11 as core

# Maintainer is deprecated, use LABEL.
# MAINTAINER Johan Bergström <bugs@bergstroem.nu>

# Build-time metadata as defined at http://label-schema.org
# DEPRECATED IN FAVOUR OF OCI IMAGE SPEC !!!
# https://github.com/opencontainers/image-spec
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="mariadb-alpine" \
      org.label-schema.description="A MariaDB container suitable for development" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/jbergstroem/mariadb-alpine" \
      org.label-schema.schema-version="1.0.0-rc.1" \
      org.label-schema.license="Apache-2.0"

COPY run.sh /run.sh
COPY my.cnf /tmp/

RUN \
  export sharedir=/usr/share/mariadb \
  # Need bash for evaluating path name expansions.
  && apk add --no-cache mariadb=10.4.10-r0 bash \
  && rm -rf /etc/my.cnf.d/* /etc/my.cnf.apk-new /usr/data/test/db.opt \
   #   /usr/share/mariadb/README* /usr/share/mariadb/COPYING* /usr/share/mariadb/*.cnf \
     /usr/share/terminfo \
     # /usr/mysql-test dir is 321MB on 10.4
     /usr/mysql-test \
     # Is PERL required for operation? Also seems there's two of them.
     /usr/share/perl5 \
     /usr/lib/perl5 \
  # /usr/bin @ 97MB: No need for advanced backups, compression (mbstream)
  && /bin/bash -c 'rm -rf /usr/bin/{mysql,mariabackup,mbstream,my_print_defaults,perror,pod*,resolveip,perl*,my_safe_process}' \
  && /bin/bash -c 'rm -rf /usr/bin/mysql{admin,check,dump,import,show,test*,access,dumpslow,hotcopy,_isntall_db}' \
  && /bin/bash -c 'rm -rf ${sharedir}/{README*,COPYING*,*.cnf}' \
  && /bin/bash -c 'rm -rf ${sharedir}/{binary-configure,mysqld_multi.server,mysql-log-rotate,mysql.server,install_spider.sql,fill_help_tables.sql}' \
  && find ${sharedir} -mindepth 1 -type d ! -name 'charsets' ! -name 'english' -print0 | xargs -0 rm -rf \
  && touch ${sharedir}/mysql_system_tables_data.sql \
  && mkdir /run/mysqld \
  && chown mysql:mysql /etc/my.cnf.d/ /run/mysqld ${sharedir}/mysql_system_tables_data.sql \
  && for p in aria* myisam* mysqld_* innochecksum \
              mysqlslap replace wsrep* msql2mysql sst_dump \
              resolve_stack_dump mysqlbinlog myrocks_hotbackup test-connect-t \
              $(cd /usr/bin; ls mysql_*| grep -v mysql_install_db); \
              do eval rm /usr/bin/${p}; done \
  # Not using pam for authentication.
  && /bin/bash -c 'rm -rf /lib/{libpam*,security}' \
  # APK cleanup, remove changes in new layer ~1.3MB.
  && apk del --purge bash && rm -rf /lib/apk/db \
  # Compression, PCRE, libstdc++, libxml, ssl, tls.
  && rm -rf /usr/lib/libxml* /usr/lib/libpcre* /usr/lib/libstd* /usr/lib/libpanel* /usr/lib/libncurses* /usr/lib/libme* /usr/lib/liblzma* \
    /usr/lib/libgcc* /usr/lib/libform* /usr/lib/libbz* /usr/lib/libaio* /usr/lib/libz* /usr/lib/mariadb

USER mysql

# This is not super helpful; mysqld might be running but not accepting connections.
# Since we have no clients, we can't really connect to it and check.
#
# Below is in my opinion better than no health check.
HEALTHCHECK --start-period=3s CMD pgrep mysqld

VOLUME ["/var/lib/mysql"]
ENTRYPOINT ["/run.sh"]
EXPOSE 3306
