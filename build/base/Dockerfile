FROM ubuntu:xenial-20160818
MAINTAINER Richard Alexander Allen <richard.alexander.allen@gmail.com>

ARG ANSIBLE_LIMIT
ARG ANSIBLE_PLAYBOOK

# Make Ansible inventory available to Docker build.
COPY inventory /etc/ansible
COPY provisioners/ansible /opt/localenv/ansible

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update \
    # Install Python dependencies.
    && apt-get -y install python-software-properties software-properties-common \
    # Install and upgrade Python PIP.
    && apt-get -y install python-pip \
    && pip install --upgrade pip \
    # Install Supervisor.
    && apt-get install -y supervisor \
    && mkdir -p /var/log/supervisor \
    && pip install supervisor-stdout \
    # Install Ansible and provision base dependencies with Ansible.
    && add-apt-repository ppa:ansible/ansible \
    && apt-get update \
    && apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    install -y ansible \
    # Execute Ansible playbook for base image.
    && ansible-playbook --connection=local --limit=$ANSIBLE_LIMIT $ANSIBLE_PLAYBOOK

# Clean-up installation.
RUN DEBIAN_FRONTEND=noninteractive apt-get -qy autoclean && apt-get -qy autoremove

# Configurations for bash.
RUN echo "export TERM=xterm" >> /etc/bash.bashrc
