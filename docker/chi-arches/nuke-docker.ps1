# remove every docker component used in the session (images, containers, networks etc)

docker container stop $(docker container ls -a -q) && docker system prune -a -f --volumes