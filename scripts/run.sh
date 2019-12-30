#!/bin/bash

# Using user-defined network eliminates need to use service links,
# and allows multiple compose stacks to join/leave network on a as-needed basis -
# as opposed to composing up or down an entire monolith compose stack.
#
# For benefits of user-defined bridge over default bridge https://docs.docker.com/network/bridge/
# Compose networking: https://docs.docker.com/compose/networking/
# Latest compose reference: https://docs.docker.com/compose/compose-file/#network-configuration-reference

# Create user-defined bridge.
USER_NETWORK=localenv

NETEXISTS=`docker network ls | grep -c $USER_NETWORK`
if ! (($NETEXISTS)) ; then
  echo "Create user-defined network"
  docker network create $USER_NETWORK
else
  echo "Docker network ${NETEXISTS} already exists, joining."
fi

# Bring down stack if it exists.
docker-compose down
docker-compose up -d
docker-compose ps
