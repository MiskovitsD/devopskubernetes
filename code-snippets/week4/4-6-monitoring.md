# Monitoring dependency to pom.xml

```
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-registry-prometheus</artifactId>
            <scope>runtime</scope>
        </dependency>

```

# Monitoring configuration

Put this into src/main/resources/application.properties:

```
management.endpoints.web.exposure.include=health,prometheus
```

# Alerting query

```
increase(http_server_requests_seconds_count{namespace="cubix", container="api", outcome="SERVER_ERROR"}[1m])
```
