FROM base
LABEL maintainer="AlexanderAllen <14018885+AlexanderAllen@users.noreply.github.com>"

# Where the IDE will connect to.
ARG DBGP_IDE_PORT
# Where XDebug will connect to.
ARG DBGP_DEBUG_LISTEN

ENV DBGP_IDE_PORT=$DBGP_IDE_PORT \
    DBGP_DEBUG_LISTEN=$DBGP_DEBUG_LISTEN

# Install Komodo dbgp proxy.
RUN pip install komodo-python-dbgp

# Copy supervisor configiguration.
COPY provisioners/docker/dbgp-proxy/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# https://github.com/docker/docker/blob/master/docs/examples/running_ssh_service.md

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

CMD /usr/bin/supervisord
