#!/usr/bin/env bash

# Use this for OSX where socket forwarding doesn't work.
# Dont need on Linux/Windows.
# SSH_ENV="$HOME/.ssh/docker-environment"

# function start_agent {
#     echo "Initialising new SSH agent..."
#     (umask 066; /usr/bin/ssh-agent > "${SSH_ENV}")
#     . "${SSH_ENV}" > /dev/null
#     ssh-add "${SSH_PRIVATE_KEY}"
# }

# # Source SSH settings, if applicable

# if [ -f "${SSH_ENV}" ]; then
#     . "${SSH_ENV}" > /dev/null
#     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
#         start_agent;
#     }
# else
#     start_agent;
# fi

# # Customizations provided by drush9+
# # Include Drush bash customizations.

# if [ -f "/root/.drush/drush.bashrc" ] ; then
#   source /root/.drush/drush.bashrc
# fi

# # Include Drush prompt customizations.
# if [ -f "/root/.drush/drush.prompt.sh" ] ; then
#   source /root/.drush/drush.prompt.sh
# fi
