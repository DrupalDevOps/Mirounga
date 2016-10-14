LOCALENV
========

Local development environment using Docker and Alpine Linux.

## Table of Contents

* [Documentation](#documentation)

## Documentation

Docker Compose File
https://docs.docker.com/compose/compose-file

Docker Compose Command Line
https://docs.docker.com/compose/reference/

A good idea on how to use a entrypoint shell script:
https://github.com/MetalGuardian/docker-php-fpm/blob/master/Dockerfile

General PHP-FPM + Nginx Dockerization Guide with GIFs
http://geekyplatypus.com/dockerise-your-php-application-with-nginx-and-php7-fpm/

## Alpine Linux

Alpine Linux is a Linux distribution built around musl libc and BusyBox. 
The image is only 5 MB in size and has access to a package repository that is much more complete than other BusyBox 
based images. This makes Alpine Linux a great image base for utilities and even production applications.

The various versions of docker images are available here:

https://hub.docker.com/_/alpine/

Read more about Alpine here: https://www.alpinelinux.org/about/

About the Alpine Docker image: http://gliderlabs.viewdocs.io/docker-alpine/

## Memcached

Docs for running Memcached daemon: https://github.com/memcached/memcached/wiki/ConfiguringServer

Help with the daemon: `memcached -h`, `man memcached`.

## XDebug Networking with Docker for Mac

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

## Docker Compose

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
    
## Docker Compose Debugging
    
Provisioning manually (for troubleshooting Ansible playbook)

    docker-compose run --entrypoint bash php-fpm
    Starting localenv_base
    root@341798fd2c4c:/# . /opt/localenv/shell/entrypoint.sh

Provision manually a service

* To see in real-time the output of the service.
* To guess from the real-time output what is failing during service creation.

    
    docker-compose run nginx

## Docker commands

Save an image

    docker commit localenv_nginx_1
    sha256:272eb74b60edb7ecb87f0ccde57736b8f0397177096a8389c1211cfffe73eb32

Login to a registry

    docker login --username foobar --password baz
    Login Succeeded
    
CLEANUP: Remove all images

    docker rmi $(docker images -q)
    
NUKE ABSOLUTELY EVERYTHING

    docker rmi -f $(docker images -q)
    

## Docker Networking

Check container route

    docker-compose exec dbgp-proxy bash
    root@d0e314ede4f5:/# route -n
    Kernel IP routing table
    Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
    0.0.0.0         172.18.0.1      0.0.0.0         UG    0      0        0 eth0
    172.18.0.0      0.0.0.0         255.255.0.0     U     0      0        0 eth0

Check open ports within container

netstat -lnp | grep 1234

# Supervisor Log redirection

http://veithen.github.io/2015/01/08/supervisord-redirecting-stdout.html

# Working with supervisor

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


## Manually restart a process

    root@b5feaeb8eabb:/# supervisorctl start dbgp-proxy

## Tagging, Pulling, Repositories

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
    

## MariaDB

Documentation:

- https://hub.docker.com/_/mariadb/
- https://hub.docker.com/_/mysql/
- https://mariadb.com/kb/en/mariadb/installing-and-using-mariadb-via-docker/

Fancy GUI client

    brew cask install navicat-for-mysql
    
Connect to MySQL using Docker
    
    docker run -it --link mysql:mysql --rm mysql sh -c 'exec mysql -hmariadb-10.1 -P3306 -uroot -proot
    
Get a list of all startup options

    docker run -it --rm mariadb:10.1 --verbose --help
    
Check what are the available charsets
    
    root@mariadb-10:ls /usr/share/mysql/charsets/
    Index.xml  armscii8.xml  cp1250.xml  cp1256.xml  cp850.xml  cp866.xml  geostd8.xml  hebrew.xml	keybcs2.xml  koi8u.xml	 latin2.xml  latin7.xml  macroman.xml
    README	   ascii.xml	 cp1251.xml  cp1257.xml  cp852.xml  dec8.xml   greek.xml    hp8.xml	koi8r.xml    latin1.xml  latin5.xml  macce.xml	 swe7.xml    

## Composer

    docker-compose run --rm composer [command] [options] [arguments]

## Drush

    docker-compose run --rm drush [drush command]

## DBGp Proxy

Due to limitations in Docker for Mac, the DBGp service is not enabled by default. To enable it, use the compose file 
extension syntax: 

    docker-compose -f docker-compose.yml -f docker-compose.dbgp.yml up -d

This will route XDebug communication through the DBGp proxy container. 
