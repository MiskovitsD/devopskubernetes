# Testing out Docker pull

How an image's name is set up.

```shell
docker pull alpine:3.17.0
```

```shell
docker pull quay.io/drsylent/docker-tutorial:script
```

```shell
docker images
```

```shell
docker history quay.io/drsylent/docker-tutorial:script
```

# Running a container

	docker run quay.io/drsylent/docker-tutorial:script
	docker ps -> empty
	docker ps -a -> one stopped container
	docker logs -> we can see the output
	docker rm -> put in the name of the container
	docker ps -a -> it is deleted

# Enter a container

	docker run –name enter alpine:3.17.0
	docker ps -a -> exited
	docker inspect enter -> we can see all data
	docker inspect alpine:3.17.0 -> we can see all data for just the image
	docker rm enter
	docker run –name enter -it alpine:3.17.0 -> we open a shell

```shell
ls
exit
```

```shell
docker rm enter
```

# Run directly with a shell and manual image snapshot

	docker inspect quay.io/drsylent/docker-tutorial:script
	docker run –name edit -it –entrypoint sh quay.io/drsylent/docker-tutorial:script
	cat script.sh
	echo "echo Hello Edited World!" > script.sh
	cat script.sh
	exit
	docker commit edit script-rewritten
	docker rm edit
	docker run --name rewritten script-rewritten -> nothing happens!
	docker ps -a -> the command was overwritten by sh
	docker rm rewritten
	docker run --name rewritten --entrypoint sh script-rewritten -c ./script.sh → this is the way
	docker commit rewritten script-rewritten
	docker rm rewritten
	docker run --rm --name rewritten script-rewritten

# Handling and deleting images

	docker images -> the previous image is still there without any name
	docker rmi <old ID> -> 2 layers were deleted: the changed command and the result of shell session

# Change the image - copy the script and make it so that environment variable is used for the message

	docker run --rm --name from -d --entrypoint sleep quay.io/drsylent/docker-tutorial:script 300
	docker ps → runs
	docker cp from:script.sh script.sh
	docker stop from → wont stop (sleep is not interrupted) - will be killed after 10 seconds

script.sh change -> World replaced by $VARIABLE

Create a Dockerfile and explain the lines:

```Dockerfile
FROM alpine:3.17.0

LABEL Tutorial="Cubix Cloud Native" Author="Dávid Csendes"

COPY script.sh script.sh
RUN chmod 744 script.sh
ENV VARIABLE=World

ENTRYPOINT [ "/bin/sh", "-c" ]
CMD [ "./script.sh" ]
```

```
docker build -t script-env .
docker inspect script-env
docker run --rm --name env script-env → default Hello World
docker run --rm --name env -e VARIABLE=Docker script-env → env variable works
```

# Check the user that runs and fix if it is not good

```
docker run --rm --name user --entrypoint whoami script-env → root
```

End of the Dockerfile: USER 1001

	docker build -t script-env .
	docker run --rm --name env script-env → permission denied
	docker run --rm --name env -u 0 script-env → okay
  
Fix Dockerfile:

```Dockerfile
USER 1001

COPY --chown=1001 script.sh script.sh
```

```shell
docker build -t script-env .
docker run --rm --name env script-env
```

```
docker run --rm --name user --entrypoint whoami script-env → non-root
```
