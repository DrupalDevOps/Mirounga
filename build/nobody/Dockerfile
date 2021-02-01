ARG ALPINE_MAJOR=3
ARG ALPINE_MINOR=12

FROM alpine:${ALPINE_MAJOR}.${ALPINE_MINOR}
LABEL maintainer="14018885+AlexanderAllen@users.noreply.github.com"

ARG DOCKER_USER=nobody
ARG USER_UID=1000
ARG USER_GECOS=""

RUN \
  apk add --no-cache su-exec \
  # Reset existing user to desired uid/gid.
  && id ${DOCKER_USER} \
  && deluser ${DOCKER_USER} 2> /dev/null \
  && adduser --disabled-password --gecos "${USER_GECOS}" --uid ${USER_UID} ${DOCKER_USER} \
  # Adding user to tty group allows non-root logging into file descriptors such as /dev/stdout.
  && addgroup ${DOCKER_USER} tty \
  # Print new uid/gid confirmation.
  && groups ${DOCKER_USER} && id ${DOCKER_USER}
