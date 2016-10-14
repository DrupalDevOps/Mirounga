FROM base:latest
MAINTAINER Richard Alexander Allen <richard.alexander.allen@gmail.com>

# Define arguments used for build.
ARG ANSIBLE_LIMIT
ARG ANSIBLE_PLAYBOOK
# ARG NGINX_WEB_ROOT
ARG NGINX_HTTP_LISTEN
ARG NGINX_PHPFPM_FASTCGI_PASS
ARG NGINX_LOGLEVEL

# Get environment variables needed by the Ansible provisioner from the build arguments.
ENV NGINX_HTTP_LISTEN=$NGINX_HTTP_LISTEN \
    NGINX_PHPFPM_FASTCGI_PASS=$NGINX_PHPFPM_FASTCGI_PASS \
    NGINX_LOGLEVEL=$NGINX_LOGLEVEL

# Make Ansible inventory available to Docker build.
COPY inventory /etc/ansible
COPY provisioners/ansible /opt/localenv/ansible

# Install Nginx.
RUN ansible-playbook --connection=local --limit=$ANSIBLE_LIMIT $ANSIBLE_PLAYBOOK

# Copy dynamic vhost definition into container.
# Use one container for each application, using environment variables passed to the run command.
COPY provisioners/docker/nginx/vhost.conf /etc/nginx/sites-enabled/vhost.conf

# Clean-up installation.
RUN DEBIAN_FRONTEND=noninteractive apt-get autoclean && apt-get autoremove

# Copy supervisor configiguration.
COPY provisioners/docker/nginx/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configurations for bash.
RUN echo "export TERM=xterm" >> /etc/bash.bashrc
