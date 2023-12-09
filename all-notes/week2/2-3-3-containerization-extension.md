# Try out the EXPOSE instruction

We have seen previously, that everything worked just fine. There is however one Dockerfile instruction you might encounter and we haven't talked about.

Modify the `Dockerfile-aftermaven` file:

```Dockerfile
EXPOSE 8080
```

This is similar to what we do with the -p argument - but only for documentation! It will NOT expose the port automatically, it just informs the user, that this port should be exposed as there is something that can be reached there. By default this means TCP (just as with -p).

It can be used however by applying uppercase, -P. This will automatically expose all documented ports.

Use the commands from `docker-run-from-local` script:

```shell
docker build -f Dockerfile-aftermaven -t cloud-native-demo:tutorial .
docker run -P --rm --name demo -it cloud-native-demo:tutorial
```

Try out the call - it will succeed.

# Try out how the build context works

Clone another repository.

Check the repository - it has a text file, a text file with the same name in a folder where there is another file, and a Dockerfile.

The Dockerfile copies the file called hello.txt and at startup it will print its contents. Try it out.

```shell
docker build -t context:test .
docker run --rm context:test
```

You will see it will print out the contents of the hello.txt from the root folder, with the content "hello".

Whenever we build with Docker, there is a build context. This is the folder from which we take the files that will be needed for the build. This is the last parameter, which most of the time will be simply a dot - the current folder.

So if we select the test folder to be the build context, it will copy the other hello.txt file, from the folder, as the build context is the test folder this time. Note, that the build context is where the Dockerfile will be looked up, so this time we must manually add the Dockerfile's location.

```shell
docker build -t context:test -f Dockerfile test
docker run --rm context:test
```

We will see the "there" text as output.

Now replace in the Dockerfile the hello.txt to other.txt. The other.txt is not in the test folder, try and do the COPY command with navigation:

```Dockerfile
COPY ../other.txt hello.txt
```

But this will fail! The build context is final - at the start of the build it is copied for Docker and the build will see only those files that are in the context - you can not move out from it.
