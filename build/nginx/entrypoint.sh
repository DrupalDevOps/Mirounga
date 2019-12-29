#!/bin/sh

# Allow forwarding of non-root user (nobody) process (nginx) log files to Docker logs.
#
# https://github.com/moby/moby/issues/31243
# https://github.com/Kong/docker-kong/pull/206/files
#
# This does not seem to work if done at build time (Dockerfile), only at run time (entrypoint.sh).
#
chmod 777 /proc/self/fd/1 /proc/self/fd/2

exec su-exec nobody /usr/sbin/nginx -g "daemon off;"
