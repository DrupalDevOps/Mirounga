#!/bin/bash

export ENVIRONMENT=dev

case $1 in

  "start")
    ./scripts/start.sh
    ;;

  "stop")
    ./scripts/stop.sh
    ;;

  "restart")
    ./scripts/stop.sh
    ./scripts/start.sh
    ;;

  "drush")
    ./scripts/drush.sh "$@"
    ;;

  "destroy")
    ./scripts/destroy.sh
    ;;

  *)
    docker-compose ps
    ;;
esac
