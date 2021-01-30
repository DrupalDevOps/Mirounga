
LOCALENV_HOME="/home/wsl/Sites/localenv"
PROJECT_NAME="${PWD##*/}"

# Tail a particular log within the nginx container.
#
# Requests proxied to PHP-FPM are sent to Docker's /dev/stdout facilities, are virtual and ephemeral.
# Requests for static assets are kept inside the container's filesystem (supplemental log).
# This makes Docker logs easier to read by showing the most relevant data (dynamic requests, php-fpm requests).

docker-compose \
--project-name $PROJECT_NAME \
--file ${LOCALENV_HOME}/run/drupal/docker-compose.vsd.yml \
exec --user=root nginx ash -c 'tail -f /home/nobody/supplemental.log'
