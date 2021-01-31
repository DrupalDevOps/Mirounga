FROM alpine:3.12
LABEL maintainer="14018885+AlexanderAllen@users.noreply.github.com"

ARG DOCKER_USER
ARG USER_UID
ARG USER_GECOS

RUN \
  apk add --no-cache su-exec \
  #
  # Reset existing user to desired uid/gid.
  && id ${DOCKER_USER} \
  && deluser ${DOCKER_USER} 2> /dev/null \
  && adduser --disabled-password --gecos "${USER_UID}" --uid ${USER_UID} ${DOCKER_USER} \
  # Add user to group tty, allows non-root container processes to log into /dev/std[out|err].
  && addgroup ${DOCKER_USER} tty \
  # Confirm new uid/gid.
  && groups ${DOCKER_USER} && id ${DOCKER_USER}
