initdb.d
========

This is a special directory that gets mounted as a volume in to the Docker container.
For for more information about it see https://hub.docker.com/_/mariadb/.

## Bash scripts

Any files in this directory ending in .sh will be executed as user `mysql`.
 
## Database dumps

Any .sql files in this directory will be executed when the container is created.
