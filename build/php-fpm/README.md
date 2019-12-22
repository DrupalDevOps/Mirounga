PHP-FPM
=======

## 1) Build

    docker-compose -f build/php-fpm/docker-compose.yml build

## 2) Verify the build

    docker-compose -f build/php-fpm/docker-compose.yml run --entrypoint=sh --rm php-fpm

    / # php --version
    PHP 5.6.26 (cli) (built: Sep 23 2016 14:47:01)
    Copyright (c) 1997-2016 The PHP Group
    Zend Engine v2.6.0, Copyright (c) 1998-2016 Zend Technologies
        with Xdebug v2.4.1, Copyright (c) 2002-2016, by Derick Rethans
        with Zend OPcache v7.0.6-dev, Copyright (c) 1999-2016, by Zend Technologies

## 3) Test the build

    docker-compose -f build/php-fpm/docker-compose.yml run --rm php-fpm

You should see something similar to:

    [22-Dec-2019 18:24:21] NOTICE: [pool www] 'user' directive is ignored when FPM is not running as root
    [22-Dec-2019 18:24:21] NOTICE: [pool www] 'group' directive is ignored when FPM is not running as root
    [22-Dec-2019 18:24:21] NOTICE: fpm is running, pid 1
    [22-Dec-2019 18:24:21] NOTICE: ready to handle connections

## If upgrading major PHP version

To see where it has moved, after opening container, run:

    / # find -name *php-fpm*

    ./var/log/php-fpm.log
    ./etc/logrotate.d/php-fpm7
    ./etc/init.d/php-fpm7
    ./etc/supervisor.d/php-fpm.ini
    ./etc/php7/php-fpm.conf
    ./etc/php7/php-fpm.d
    ./usr/sbin/php-fpm7

That should show where the binaries have moved to.

For example, from php5 to php7, the main binary moved from

    /usr/bin/php-fpm

to

    /usr/sbin/php-fpm7


## Docs

- XDebug Github (compile instructions): https://github.com/xdebug/xdebug
- XDebug install: https://xdebug.org/docs/install
- PHPDBG: http://phpdbg.com/docs
