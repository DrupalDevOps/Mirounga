LOCALENV
========

This a reference Docker Compose project for Drupal, running locally
using Docker for Mac, and built 100% with Alpine Linux.

## Table of Contents

- [LOCALENV](#localenv)
  - [Table of Contents](#table-of-contents)
  - [Some Assembly Required](#some-assembly-required)
  - [Stack Components](#stack-components)
    - [Composer](#composer)
    - [Drush](#drush)
    - [Memcached](#memcached)
    - [MariaDB](#mariadb)
    - [Nginx](#nginx)
  - [XDebug](#xdebug)
    - [Web Server Debugging](#web-server-debugging)
    - [CLI Debugging](#cli-debugging)
  - [XHProf](#xhprof)
  - [Advanced Usage](#advanced-usage)
    - [Docker Compose](#docker-compose)
    - [Docker CLI Usage](#docker-cli-usage)
    - [Supervisor](#supervisor)
    - [Alpine Linux](#alpine-linux)
  - [Use Cases](#use-cases)
  - [Additional Documentation](#additional-documentation)
    - [Inspiration](#inspiration)
    - [TO DO:](#to-do)

## Some Assembly Required

__To build and run this project__:

(Not very useful by itself, since the default docker-compose.yml does not set up an example web site).

1. Download the git repo

        git clone git@github.com:rallen-temp/localenv.git localenv
        cd localenv

2. Run the `build` command, referencing all the relevant build files:

        docker-compose \
        -f build/openresty/docker-compose.yml \
        -f build/mariadb/docker-compose.yml \
        -f build/php-fpm/docker-compose.yml \
        -f build/php-cli/docker-compose.yml \
        -f build/drush/docker-compose.yml \
        -f build/xhprof/docker-compose.yml \
        build

3. Start the all services described in `docker-compose.yml`:

        docker-compose run -d

4. Watch the output from all the containers as they run:

        docker-compose logs -f

5. When you're done with it, clean it up:

        docker-compose down

__Adding your own website__

Substitute step #3 above with:

    cd localenv
    docker-compose -f ../my-awesome-sauce-site/docker-compose.yml -f docker-compose.yml up -d
    docker-compose -f ../my-awesome-sauce-site/docker-compose.yml -f docker-compose.yml ps
    docker-compose -f ../my-awesome-sauce-site/docker-compose.yml -f docker-compose.yml logs -f
    ...
    docker-compose -f ../my-awesome-sauce-site/docker-compose.yml -f docker-compose.yml down

An example in action:

An example of running the stack, entering a drush container, getting the drush version, then initiating a
CLI debugging session.

[![asciicast](https://asciinema.org/a/89661.png)](https://asciinema.org/a/89661)

## Stack Components

### Composer

The PHP-CLI image provides a container running the latest version of Composer,
along with the Z Shell, Drupal Coder Sniffer, and other typical development
dependencies for Drupal. By default this container is configured to be run
interactively, as opposed as a binary. You can use this container to install
additional Composer dependencies as well. The default login shell is ZSH.

To run, use:

    docker-compose \
    -f build/php-cli/docker-compose.yml \
    run --rm drush9-prod

### Drush

The two most currently used versions of Drush are supported in two different images.

The drush containers are meant to be run interactively as well.

To run the Drush 7 container, use:

    docker-compose \
    -f build/drush/docker-compose.yml \
    run --rm drush-7

To run the Drush 8 container, use:

    docker-compose \
    -f build/drush/docker-compose.yml \
    run --rm drush-8

The default interactive shell for the Drush containers is the Z shell.

### Memcached

This stack is using the latest official Alpine Linux Memcached image available from Docker Hub.

__Additional information:__

- Running Memcached as a daemon: https://github.com/memcached/memcached/wiki/ConfiguringServer
- Help with the daemon: `memcached -h`, `man memcached`.

### MariaDB

Using a custom version of the official MariaDB DockerHub image for MySQL.

Documentation:

- https://hub.docker.com/_/mariadb/
- https://hub.docker.com/_/mysql/
- https://mariadb.com/kb/en/mariadb/installing-and-using-mariadb-via-docker/

Get you a fancy GUI client (on OS X, requires license):

    brew cask install navicat-for-mysql

Open a CLI console to MySQL

    docker run -it --link mysql:mysql --rm mysql sh -c 'exec mysql -hmariadb-10.1 -P3306 -uroot -proot'

Get a list of all startup options

    docker run -it --rm mariadb:10.1 --verbose --help

Check what are the available charsets

    root@mariadb-10:ls /usr/share/mysql/charsets/
    Index.xml  armscii8.xml  cp1250.xml  cp1256.xml  cp850.xml  cp866.xml  geostd8.xml  hebrew.xml	keybcs2.xml  koi8u.xml	 latin2.xml  latin7.xml  macroman.xml
    README	   ascii.xml	 cp1251.xml  cp1257.xml  cp852.xml  dec8.xml   greek.xml    hp8.xml	koi8r.xml    latin1.xml  latin5.xml  macce.xml	 swe7.xml

### Nginx

For the reference web server, this stack uses a custom image with the OpenResty Nginx distribution.

The custom image builds OpenResty from scratch to have full control of OpenResty's install location and configuration.

The reason for using OpenResty is that:

- It provides easy support for environment variables out of the box;
- Baking in support for environment variables on the non-OpenResty Nginx distribution is more involved;
- Nginx does not come with support for environment variables out of the box;
- Environment variables are almost a "must have" feature when using Docker, allowing certain parameters (such as the web root, or listening port);
  to be configured at run time, as opposed to build time.

The installation can be further customized by modifying the `Dockerfile` in the `build/openresty` directory.

The default Nginx install location is set to the more familiar /etc/nginx (instad of OpenResty's default).

The default web root in the nginx containers is `/var/www`, to which you are suggested to mount your own web root.

This stack expects the user to instantiate a separate nginx container for each virtual host / code project the user is
intends to run, as opposed to putting all virtual hosts inside a single container.

As with the other services in this project, you must build the images yourself before referencing them in Docker Compose.

This is an example Docker Compose implementation for this stack's nginx image:

    version: '2'
    services:
      hello-there:
        image: alexanderallen/openresty:latest
        environment:
          NGINX_VHOST_NAME: hello-world
          NGINX_WEB_ROOT: /var/www/hello-world
          NGINX_HTTP_LISTEN: 80
          NGINX_PHPFPM_FASTCGI_PASS: phpservice:9010
          # Can be debug | info | notice | warn | error | crit | alert | emerg.
          NGINX_LOGLEVEL: crit
        links:
          - php-fpm:phpservice
        ports:
          - 80:80
        volumes_from:
          - php-fpm

At the moment this stack does not provide a default Nginx service implementation in the main `docker-compose.yml` file.
Customize the example above to suit your needs, then add to `docker-compose.yml`.

## XDebug

This stack provides full XDebug support and integration out of the box.

XDebug provides two major components:

- Web Debugging: where you debug a web page that you are viewing in your browser, and;
- CLI Debugging: there is no web browser involved at all, you are debugging a command-line based script such
as Drush or Composer.

### Web Server Debugging

Stb.

### CLI Debugging

All the PHP CLI services in this stack use the custom `build/php-fpm/Dockerfile` image
as a base image, which comes with XDebug installed. Therefore the services defined in the
following images support XDebug out of the box:

- Composer / CLI Tools services: `build/php-cli/Dockerfile`
- Drush services: `build/drush/Dockerfile`

Activating XDebug for the command line is a matter of enabling these two environment variables in
whatever docker-compose.yml file you are using:

    PHP_IDE_CONFIG: "serverName=docker"
    XDEBUG_CONFIG: "idekey=COMPOSER"

Example Docker Compose definition for drush service, with CLI debugging enabled by default:

      drush:
        image: alexanderallen/drush:7.x
        environment:
          XDEBUG_SHOW_EXCEPTION_TRACE: 0
          ## Set these two variables to debug w/ PHPStorm and XDebug.
          PHP_IDE_CONFIG: "serverName=docker"
          XDEBUG_CONFIG: "idekey=COMPOSER"
        links:
          - mysql:mysql
          - memcached:memcached
        volumes:
          - ~/Sites:/www

Note that this will cause the debugger to try to initiate a connection to your IDE for every command run
in that drush service.

As an alternative, you can instruct PHP to attempt to contact the IDE "on-demand" by setting the same envrionment
variables manually.

    Stubs.

## XHProf

This stack provides full XHProf support.
XHProf is run as it's own separate container on top of the Nginx image.

Stub: What is XHProf.
Stub: How to use XHProf.

## Advanced Usage

Intended for Docker Power Users

### Docker Compose

Bring it up

    docker-compose up -d

    docker-compose ps
         Name                    Command               State     Ports
    --------------------------------------------------------------------
    localenv_base     ansible-playbook --connect ...   Exit 0
    localenv_phpfpm   /opt/localenv/shell/entryp ...   Up       9000/tcp

Stop it

    docker-compose ps
         Name                    Command               State     Ports
    --------------------------------------------------------------------
    localenv_base     ansible-playbook --connect ...   Exit 0
    localenv_phpfpm   /opt/localenv/shell/entryp ...   Up       9000/tcp
    ➜  localenv git:(docker-v1) ✗ docker-compose stop
    Stopping localenv_phpfpm ... done

Recreate

    docker-compose kill && docker-compose rm -f && docker-compose up -d --remove-orphans

Tear it down

    docker-compose down

Tail the log/output of a specific service (after running `docker-compose up`):

    docker-compose up
    ...
    docker-compose logs -f php-fpm

Log in to the container (if the service was created and is running successfully)

    docker-compose exec php-fpm bash
    root@17328b3d14e3:/# php --version
    PHP 5.6.25-2+deb.sury.org~xenial+1 (cli)
    Copyright (c) 1997-2016 The PHP Group
    Zend Engine v2.6.0, Copyright (c) 1998-2016 Zend Technologies
        with Zend OPcache v7.0.6-dev, Copyright (c) 1999-2016, by Zend Technologies


Only start a specific service once it's been (successfully) provisioned

    ➜  localenv git:(docker-v1) ✗ docker-compose start php-fpm
    Starting php-fpm ... done
    ➜  localenv git:(docker-v1) ✗ docker-compose ps
         Name                    Command               State    Ports
    -----------------------------------------------------------------
    localenv_base     ansible-playbook --connect ...   Exit 1
    localenv_phpfpm   ansible-playbook --connect ...   Up

Stop a specific service

    docker-compose ps
         Name                    Command               State     Ports
    --------------------------------------------------------------------
    localenv_base     ansible-playbook --connect ...   Exit 0
    localenv_phpfpm   /opt/localenv/shell/entryp ...   Up       9000/tcp
    ...

    docker-compose stop php-fpm
    Stopping localenv_phpfpm ... done
    ...

    docker-compose ps
         Name                    Command                State     Ports
    -------------------------------------------------------------------
    localenv_base     ansible-playbook --connect ...   Exit 0
    localenv_phpfpm   /opt/localenv/shell/entryp ...   Exit 137


### Docker CLI Usage

Save an image

    docker commit localenv_nginx_1
    sha256:272eb74b60edb7ecb87f0ccde57736b8f0397177096a8389c1211cfffe73eb32

Login to a Docker image registry

    docker login --username foobar --password baz
    Login Succeeded

CLEANUP: Remove all images

    docker rmi $(docker images -q)

NUKE ABSOLUTELY EVERYTHING

    docker rmi -f $(docker images -q)

__Docker Networking__

Check container route

    docker-compose exec dbgp-proxy bash
    root@d0e314ede4f5:/# route -n
    Kernel IP routing table
    Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
    0.0.0.0         172.18.0.1      0.0.0.0         UG    0      0        0 eth0
    172.18.0.0      0.0.0.0         255.255.0.0     U     0      0        0 eth0

Check open ports within container

    netstat -lnp | grep 1234

__Tagging, Pulling, Repositories__

Tag an image

    # Get image ID

    docker images
    ...
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    localenv_base       latest              76cede688b96        29 hours ago        365.7 MB
    ...

    # Tag image

    docker tag 76cede688b96 alexanderallen/base

    # Push image

    docker push alexanderallen/base
    ...
    The push refers to a repository [docker.io/alexanderallen/base]
    29355864a7a4: Pushing [=============>                                     ] 55.54 MB/200.1 MB
    177cdb03585d: Pushing [=============================>                     ] 23.29 MB/38.91 MB
    0cad5e07ba33: Mounted from library/ubuntu
    48373480614b: Mounted from library/ubuntu
    055757a19384: Mounted from library/ubuntu
    c6f2b330b60c: Mounted from library/ubuntu
    c8a75145fcc4: Mounted from library/ubuntu

### Supervisor

__More information__:

* Supervisor Log redirection: http://veithen.github.io/2015/01/08/supervisord-redirecting-stdout.html

__Working with supervisor__

At any time you can run the `supervisorctl` command to bring up supervisor's console.
To see what commands you have available, type `help` in the console.
The example below restarts Nginx using the supervisor prompt:

    root@6530be0aa3d7: supervisorctl
    nginx                            RUNNING   pid 9, uptime 0:27:54
    supervisor> help

    default commands (type help <topic>):
    =====================================
    add    exit      open  reload  restart   start   tail
    avail  fg        pid   remove  shutdown  status  update
    clear  maintail  quit  reread  signal    stop    version

    supervisor> reload nginx
    Really restart the remote supervisord process y/N? y
    Restarted supervisord
    supervisor> status
    nginx                            RUNNING   pid 42, uptime 0:00:03


__Manually restart a process__

    root@b5feaeb8eabb:/# supervisorctl start dbgp-proxy

### Alpine Linux

The main reason for using Alpine Linux is that even for large images with many dependencies, such as when configuring
PHP-FPM for usage with Drupal, the image size is relatively small compared to the more popular Ubuntu variants.

For example, using Ubuntu as the base operating system, the PHP-FPM image in this stack would weight an average of
800MB after everything is installed.
By contrast, the current PHP-FPM image for this stack comes in at around 200MB.

When all components of the Docker stack are taken into consideration, the hard drive footprint of Alpine Linux is
much smaller than Ubuntu, and orders of magnitude greater when compared to a traditional Vagrant-based virtual machine.

Alpine Linux is a Linux distribution built around musl libc and BusyBox.
The image is only 5 MB in size and has access to a package repository that is much more complete than other BusyBox
based images. This makes Alpine Linux a great image base for utilities and even production applications.

More information:
The various versions of docker images are available here:

* [Alpine Linux Images](https://hub.docker.com/_/alpine/)
* [About Alpine Linux (in general)](https://www.alpinelinux.org/about/)
* [Alpine Docker Image](http://gliderlabs.viewdocs.io/docker-alpine/)

## Use Cases

__XDebug Networking with Docker for Mac__

In order for XDebug to work properly:

1. You must create a host alias `sudo ifconfig lo0 alias 10.254.254.254`.
2. You must tell XDebug to connect to this alias instead of the default Docker gateway address.
3. **DO NOT ENABLE `xdebug.remote_connect_back`**. If this is enabled, XDebug ignores the remote host directive
   (set to the host alias), and instead sees and attempts to use the Docker gateway address of `172.18.0.1` on Docker
   Mac, resulting in **epic fail** as shown below:

        /tmp # cat xdebug.log
        Log opened at 2016-10-09 22:25:56
        I: Checking remote connect back address.
        I: Checking header 'HTTP_X_FORWARDED_FOR'.
        I: Checking header 'REMOTE_ADDR'.
        I: Remote address found, connecting to 172.18.0.1:9000.
        E: Could not connect to client. :-(
        Log closed at 2016-10-09 22:25:56

Make sure xdebug.remote_connect_back is set equals zero.

## Additional Documentation

* [Docker Compose File](https://docs.docker.com/compose/compose-file)
* [Docker CLI](https://docs.docker.com/compose/reference/)
* [PHP-FPM entrypoint example](https://github.com/MetalGuardian/docker-php-fpm/blob/master/Dockerfile)
* [General PHP-FPM + Nginx Dockerization Guide with GIFs](http://geekyplatypus.com/dockerise-your-php-application-with-nginx-and-php7-fpm)

### Inspiration

The Docker images in Docker Hub were a great inspiration when writing this stack, and a lot of the patterns utilized
here where freely taken from there, with particular attention to the PHP, Composer, and OpenResty project images.

- OpenResty: https://hub.docker.com/r/openresty/openresty/
- PHP-FPM (Alpine): https://github.com/docker-library/php/blob/1c56325a69718a3e3cf76179e75d070b7e23da62/5.6/alpine/Dockerfile
- PHP-FPM: https://hub.docker.com/_/php/
- Composer: https://hub.docker.com/r/composer/composer/

### TO DO:

- Create example website project on Github (vanilla Drupal 7), and show how to integrate it with ascii cinema.
- Implement XHGUI interface for XHProf: https://inviqa.com/blog/profiling-xhgui
- Provide an ez install script that builds and runs the images (done, working, verify)
- images and ascii examples in readme
- Ready-to-use Drupal example site,
- Examples for other PHP frameworks
- Example for Drupal 8.
- Example on how to profile Drush using XHProf
- Provide binary "linting" container for phpcs, phpmd, for use with PHPStorm.
