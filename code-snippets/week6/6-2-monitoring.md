# Monitoring dependency to pom.xml

```xml
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-registry-prometheus</artifactId>
            <scope>runtime</scope>
        </dependency>

```

# Monitoring configuration

Put this into src/main/resources/application.properties:

```properties
management.endpoints.web.exposure.include=health,prometheus
```

# Location of dashboard

[Download or copy from here](/code-snippets/week6/files/spring-boot-statistics.json)

# Alerting query

```
increase(http_server_requests_seconds_count{namespace="cubix", container="api", outcome="SERVER_ERROR"}[1m])
```
