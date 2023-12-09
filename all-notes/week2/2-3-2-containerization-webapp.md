# Lets use a webapp

Use the image from the automation exercise.

```shell
docker run -p 8080:8080 --name application -d ghcr.io/drsylent/cubix/cloudnative/demo:actions
docker ps
docker logs -f application
```

Call it from Postman/Bruno.

# Change the default message

It comes from a configuration file

```shell
docker exec -it application /bin/sh
echo default-message=Modified! > application.properties
docker stop application
docker start application
```
  
Call it from Postman/Bruno (default endpoint)

```shell
docker stop application
docker rm application
```

# Use mounting

Create a file at `config/application.properties``.

```shell
docker run -p 8080:8080 --name application -d --rm `
--mount type=bind,source=<ABSOLUTEPATH>,destination=/opt/app/config cloud-native-demo
  
docker logs -f
```

Check logs while calling from Postman/Bruno (default).

# Start another application that will use databases

We need a database for this

Will use a network - in this, name-resolving is available

```shell
docker network create cloud-native-demo
docker run --name postgres `
  -e POSTGRES_USER=user -e POSTGRES_PASSWORD=password `
  --network cloud-native-demo -d --rm postgres:15.3
```

Start the Spring Boot application

```shell
docker run -p 8080:8080 `
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/postgres -e SPRING_DATASOURCE_USERNAME=user -e SPRING_DATASOURCE_PASSWORD=password `
  --network cloud-native-demo -it --rm quay.io/drsylent/cloud-native-db-demo:springboot3
```

Call: http://localhost:8080/visit -> with each call the number will increase

Stop the Spring Boot (Ctrl+C) and Postgres

```shell
docker stop postgres
```

Restart them with the previous commands, call URL -> restarted the counter

Stop them again

Lets use volume for persistence

```shell
docker volume create cloud-native-demo
docker run --name postgres `
  -e POSTGRES_USER=user -e POSTGRES_PASSWORD=password `
  --network cloud-native-demo -d --rm `
  --mount type=volume,source=cloud-native-demo,destination=/var/lib/postgresql/data postgres:15.3
```

Start Spring Boot, call URL

Stop all and start all again, call URL -> now it persisted

Cleanup

```shell
docker volume rm cloud-native-demo
docker network rm cloud-native-demo
```

# Do the same with Docker Compose

Compose is useful as we can set up multiple containers easily through one descriptor

```yaml
services:
  postgres:
    image: postgres:15.3
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
    - "cloud-native-demo:/var/lib/postgresql/data"

  application:
    image: quay.io/drsylent/cloud-native-db-demo:springboot3
    ports:
      - 8080:8080
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/postgres
      SPRING_DATASOURCE_USERNAME: user
      SPRING_DATASOURCE_PASSWORD: password
      
volumes:
  cloud-native-demo: {}
```

`docker compose up` watch the logs (merged!) and call it.

Ctrl+C and `docker ps -a` we have the containers, `docker compose down` deletes them

`docker compose up`, call, persistence is still okay - Ctrl+C `docker compose down -v` will delete the volumes too

# Create a multi-stage build for the forked demo application

BEFOREHAND: change the line endings for Linux.

Dockerfile-multistage should be based on the Dockerfile-aftermaven:

```Dockerfile
FROM eclipse-temurin:17 AS builder

RUN mkdir /opt/build
WORKDIR /opt/build
COPY .mvn .mvn
COPY src src
COPY mvnw .
COPY pom.xml .
RUN ./mvnw clean verify

FROM eclipse-temurin:17-jre
RUN mkdir /opt/app && chown 1001 -R /opt/app
USER 1001
WORKDIR /opt/app
COPY --chown=1001 --from=builder /opt/build/target/*.jar app.jar
CMD ["java", "-jar", "app.jar"]
```

```
docker build -t cloud-native-demo:multistage -f .\Dockerfile-multistage . -> will take some time
docker run -p 8080:8080 --name application -d cloud-native-demo:multistage
```

