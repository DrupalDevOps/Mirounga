PHP-FPM
=======

## Building

docker-compose -f php-fpm.yml build

## Testing

    docker-compose -f php-fpm.yml up -d php-fpm
    docker-compose -f php-fpm.yml exec --index=1 php-fpm sh
    / # php --version
    PHP 5.6.26 (cli) (built: Sep 23 2016 14:47:01)
    Copyright (c) 1997-2016 The PHP Group
    Zend Engine v2.6.0, Copyright (c) 1998-2016 Zend Technologies
        with Xdebug v2.4.1, Copyright (c) 2002-2016, by Derick Rethans
        with Zend OPcache v7.0.6-dev, Copyright (c) 1999-2016, by Zend Technologies

## Docs

- XDebug Github (compile instructions): https://github.com/xdebug/xdebug
- XDebug install: https://xdebug.org/docs/install
- PHPDBG: http://phpdbg.com/docs
