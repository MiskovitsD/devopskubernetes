# Exec probe

Define a startupProbe, that will use an exec probe that will be unsuccessful.

deployment.yaml:

```yaml
          startupProbe:
            periodSeconds: 5
            failureThreshold: 5
            exec:
              command:
              - ls
              - /nonexistent
```

Deploy the API like this: `helm upgrade api spring-cubix --install -f api.yaml -n cubix`

Check: `kubectl get pods -w`

The Pod restarts multiple times. Do a describe on the Pod: `kubectl describe pod/... -n cubix` 
We can see the error message and that the container will be restarted because of this.

Roll back: `helm rollback api -n cubix`

Change the command to have only a simple ls and deploy it. Watch the Pods, and we can see that there are no problems.

# TCP probe

Switch to a TCP probe:

```yaml
            tcpSocket:
              port: 8080

```

Deploy and watch. When the application has successfully started, the TCP connection could be made, and the app has started.

Do the same for liveness and readiness probes, but with a named port:

```yaml
          startupProbe:
            periodSeconds: 5
            failureThreshold: 5
            tcpSocket:
              port: 8080
          livenessProbe:
            periodSeconds: 5
            failureThreshold: 2
            tcpSocket:
              port: http
          readinessProbe:
            periodSeconds: 5
            failureThreshold: 2
            tcpSocket:
              port: http
```

Push the changes, so we will have a CD process. 
The DB application might crash and restart if there are not enough resources, but eventually it should start up.

# HTTP probe

If we want to do an HTTP probe, we might try and ping a business endpoint, but it might need authentication, trigger side-effects...
Most of the time there should be a dedicated endpoint for this.

Spring Boot supports an automated way of creating an endpoint like this. API app will be modified.

pom.xml:
```xml
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
```

application.properties (this will set up to have separate liveness and readiness probes available - on Kubernetes automatically activated):

```properties
management.health.probes.enabled=true
```

Start it (might need a `./mvnw clean` command beforehand). Spring Boot's Actuator is a management interface, we can reach it like this:
http://localhost:8082/actuator

Liveness probe: http://localhost:8082/actuator/health/liveness and readiness probe: http://localhost:8082/actuator/health/readiness

# Setting up management to a different port

Now to be well-prepared, this endpoint should not be available publicly. We should put it on a separate port.
This can be configured with management.server.port as a system property or an environment variable.

Use system property for the local startup script: `-Dmanagement.server.port=9082`

Start it, and the port will change: http://localhost:9082/actuator/health/readiness - note that normal calls will still work.

# Checking the database with the readiness probe

The readiness probe should check the dependencies, whether those are ready too. This can be tricky.

For REST calls, there might be a need to use certificates, authentication, transitive dependencies...
The most simple solution might be using the Kubernetes API's Service Discovery function, which already does this.
A custom solution can be writing custom calls.

For databases, this can be simpler, thus we will prepare only the DB application.

Push the changes for the API app, and do everything for the DB app too. By default the Spring Boot will not check the DB, we must set it up:

application.properties:

```properties
management.endpoint.health.group.readiness.include=db
```

Start the DB application locally, and check the readiness endpoint: http://localhost:9081/actuator/health/readiness

Stop the local DB, and check again. After a while it will report that it is DOWN, so it works.

Push the DB application too.

# Apply the changes to Helm

Configure the management port, this time from an environment variable:

```yaml
          - name: MANAGEMENT_SERVER_PORT
            value: "9080"
```

Also save the management port as a separate port (not mandatory):

```yaml
            - name: management
              containerPort: 9080
              protocol: TCP
```

And change the health probes (for readiness the path will change):

```yaml
            httpGet:
              port: management
              path: /actuator/health/liveness
```

Deploy the API application locally and watch the Pods. Check the probe definitions with describe: `kubectl describe deploy/api-spring-cubix -n cubix`

If everything is fine, push the changes, so the changes will be applied to the DB application too. Wait for it to succeed.

# See the readiness probe in action

Do the same as we did locally: stop the database with `kubectl scale statefulset/postgresql --replicas 0 -n cubix`

Watch the readiness state: `kubectl get pods -w` After a while we can see, that the DB application's Pod has 0/1 ready containers.

Try and call the store endpoint of the API app. We'll get a 500 and in Grafana we can see that a Connection refused was thrown by the API app.

Also we can see something similar with the Service: `kubectl describe svc/db-spring-cubix -n cubix`
The Endpoints section is empty. With the API app, there is the address of the running Pod.

Scale back the database to 1 and watch the Pods. Call the store endpoint again.
