# Management (health checking) dependency to pom.xml

```xml
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
```

# Enable probes

Put this into src/main/resources/application.properties:

```properties
management.health.probes.enabled=true
```

# Management / Actuator base URL

http://localhost:8082/actuator

# System property for changing management port

For API application, in local-app/app-start script:

```shell
-Dmanagement.server.port=9082
```

In Windows, put it between quotation marks: `"-Dmanagement.server.port=9082"`

# Check database with readiness probe

Put this into src/main/resources/application.properties only for the DB application:

```properties
management.endpoint.health.group.readiness.include=db
```

# Setup Helm Chart changes

Management port setting for application:

```yaml
          - name: MANAGEMENT_SERVER_PORT
            value: "9080"
```

Setting management port as a named port:

```yaml
            - name: management
              containerPort: 9080
              protocol: TCP
```

HTTP GET probe setting:

```yaml
            httpGet:
              port: management
              path: /actuator/health/liveness
```
