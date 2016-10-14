FROM composer/composer:php5-alpine

# Add SSH client and Git to image.
RUN apk update \
    && apk add git openssh-client bash

# Since the more efficient method of agent-forwarding is not supported on all
# Docker environments, start an ssh-agent and add a key.
# Required for Composer repos that need SSH instead of HTTPS.
COPY .bashrc /root/.bashrc

WORKDIR /opt/localenv/sites
