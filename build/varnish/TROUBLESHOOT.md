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
