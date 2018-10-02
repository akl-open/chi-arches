# CHIa in Docker

## Docker

### Commands

Nuke all docker stuff (images, containers etc)
`docker container stop $(docker container ls -a -q) && docker system prune -a -f --volumes`

Mount a docker image
`docker run -d <image_name>`

Access a docker container
`docker exec -it <name> bash`

Committing to Docker Hub
1. Mount the docker image
2. Perform all the needed changes (vi...)
3. Commit container `docker commit <container name/id> <old image name>`
4. Tag Container `docker tag <old image name> <new image name>`
5. Push Container `docker push <new image name>`

## To run Arches

1. Create a project folder
2. Copy the 'docker-compose.yml' file and ensure the configurations are done.
3. Run pull to download\update the images `docker-compose pull`
4. Run hosting `docker-compose up`
5. Open browser - http://localhost:80



