# docker-compose -f build/mariadb-alpine/docker-compose.yml down \
# && docker-compose -f build/mariadb-alpine/docker-compose.yml build mariadb \
# && docker-compose -f build/mariadb-alpine/docker-compose.yml up -d \
# && docker-compose -f build/mariadb-alpine/docker-compose.yml ps \
# && docker-compose -f build/mariadb-alpine/docker-compose.yml logs

docker-compose down \
&& docker-compose build mariadb \
&& docker-compose up -d \
&& docker-compose ps \
&& docker-compose logs
