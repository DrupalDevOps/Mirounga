How To Troubleshoot The Varnish Container
=========================================

### Manually starting container and Varnish process

Run varnish container on a full Docker Compose stack with shared networking:

    export COMPOSE_NETWORK=VSD
    LOCALENV_HOME="/home/wsl/Sites/localenv"
    PROJECT_NAME="${PWD##*/}"

    docker-compose \
    --project-name $PROJECT_NAME \
    --file ${LOCALENV_HOME}/docker-compose.shared.yml \
    --file ${LOCALENV_HOME}/run/drupal/docker-compose.vsd.yml \
    run --entrypoint=ash \
    varnish

Example command

    # debug cli
    su-exec nobody /usr/sbin/varnishd \
    -d -s malloc,32M -a 0.0.0.0:80 -b nginx:8080

    # foreground process: this is how the container runs varnish
    # Use this to see if something's wrong with the Docker image, or the compose stack:

    su-exec nobody /usr/sbin/varnishd \
    -F -s malloc,32M -a 0.0.0.0:80 -b nginx:8080

Notice that here `nginx` is the name of the Docker Compose service that Varnish
must be able to reach.

If Varnish starts before the backend service, it will show an error and the container
will not work. Use the Docker container's logs to see what was the error.

## Service disambiguation

VSD is a shared bridge network setup for this Docker Compose project, defined by these two main attributes:

- A central, shared copmose stack containing a MariaDB database.
- Discrete per-project compose stacks containing a nginx, php-fpm, and varnish instance each.

Each time you launch a new application, it joins the shared VSD network so they can
talk to the database.

When multiple NGINX and Varnish containers joined the shared network, Varnish needs to know
which NGINX service to talk to.

Varnish does not use hardcoded IP addresses to talk to Nginx, it uses Docker Compose service
names. If there are multiple Nginx services on the shared network you can get this message:

    varnish_1    | Error:
    varnish_1    | Message from VCC-compiler:
    varnish_1    | Backend host "nginx:8080": resolves to too many addresses.
    varnish_1    | Only one IPv4 and one IPv6 are allowed.
    varnish_1    | Please specify which exact address you want to use, we found all of these:
    varnish_1    |  192.168.0.9:8080
    varnish_1    |  192.168.0.6:8080
    varnish_1    | ('<-b argument>' Line 3 Pos 13)
    varnish_1    |     .host = "nginx:8080";
    ...
    varnish_1    |
    varnish_1    | Running VCC-compiler failed, exited with 2
    varnish_1    | VCL compilation failed
    hello-php_varnish_1 exited with code 2

When Varnish tries to resolve the compose service name `nginx:8080`, Docker's internal
DNS returns `192.168.0.9` and `192.168.0.6`. Varnish does not know which nginx to talk to!

To clear this confusion, a per-project service alias is added for each NGINX container
instance (service), this alias is specified at the network level in the per-project Docker Compose definition `run\drupal\docker-compose.vsd.yml`.

    nginx:
      image: alexanderallen/nginx:1.17-alpine
      networks:
        VSD:
          aliases:
            # Give nginx a project-specific alias: Varnish needs to know
            # which nginx service to talk to on the shared bridge network.
            - "${PROJECT_NAME}-nginx"

The `$PROJECT_NAME` is based on the current directory and set by the `scripts\vsd-start.sh` script.

When Varnish is given the command `command: -F -s malloc,32M -a :80 -b "${PROJECT_NAME}-nginx:8080"` it then knows which backend to proxy from/to, since it is using the
network service alias. In contrast, if you specified:

    command: -F -s malloc,32M -a :80 -b "nginx:8080"

instead of:

    command: -F -s malloc,32M -a :80 -b "${PROJECT_NAME}-nginx:8080"

Then you would give you the above error !


### Reference

    / # varnishd --help
    varnishd: unrecognized option: -
    Usage: varnishd [options]

    Basic options:
      -a [<name>=]address[:port][,proto] # HTTP listen address and port
        [,user=<u>][,group=<g>]   # Can be specified multiple times.
        [,mode=<m>]               #   default: ":80,HTTP"
                                  # Proto can be "PROXY" or "HTTP" (default)
                                  # user, group and mode set permissions for
                                  #   a Unix domain socket.
      -b [addr[:port]|path]        # Backend address and port
                                  #   or socket file path
                                  #   default: ":80"
      -f vclfile                   # VCL program
                                  # Can be specified multiple times.
      -n dir                       # Working directory

    -b can be used only once, and not together with -f

    Documentation options:
      -?                           # Prints this usage message
      -x parameter                 # Parameter documentation
      -x vsl                       # VSL record documentation
      -x cli                       # CLI command documentation
      -x builtin                   # Builtin VCL program
      -x optstring                 # List of getopt options

    Operations options:
      -F                           # Run in foreground
      -T address[:port]            # CLI address
                                  # Can be specified multiple times.
      -M address:port              # Reverse CLI destination
                                  # Can be specified multiple times.
      -P file                      # PID file
      -i identity                  # Identity of varnish instance
      -I clifile                   # Initialization CLI commands

    Tuning options:
      -t TTL                       # Default TTL
      -p param=value               # set parameter
                                  # Can be specified multiple times.
      -s [name=]kind[,options]     # Storage specification
                                  # Can be specified multiple times.
                                  #   -s default (=malloc)
                                  #   -s malloc
                                  #   -s file
      -l vsl                       # Size of shared memory log
                                  #   vsl: space for VSL records [80m]

    Security options:
      -r param[,param...]          # Set parameters read-only from CLI
                                  # Can be specified multiple times.
      -S secret-file               # Secret file for CLI authentication
      -j jail[,options]            # Jail specification
                                  #   -j unix
                                  #   -j none

    Advanced/Dev/Debug options:
      -d                           # debug mode
                                  # Stay in foreground, CLI on stdin.
      -C                           # Output VCL code compiled to C language
      -V                           # version
      -h kind[,options]            # Hash specification
      -W waiter                    # Waiter implementation
