
LOCALENV_HOME="/home/wsl/Sites/localenv"
PROJECT_NAME="${PWD##*/}"

# Argument no.1 is the name of the container to connect to.
docker-compose \
--project-name $PROJECT_NAME \
--file ${LOCALENV_HOME}/run/drupal/docker-compose.vsd.yml \
exec --user=root $1 ash
