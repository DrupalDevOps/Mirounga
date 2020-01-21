# Tail non-stdio physical log in container.

docker-compose exec --entrypoint=ash --user=root $1 tail -f $2
