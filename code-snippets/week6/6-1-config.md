# ConfigMap data section

```yaml
{{ (.Files.Glob (print .Values.configMap.directory "/*")).AsConfig | indent 2 }}
```

# DB application URL setting for API application

```properties
api.message.url=http://db-spring-cubix:8080
```

# DB application configuration setting

```properties
spring.datasource.url=jdbc:postgresql://postgresql:5432/postgres
spring.datasource.username=user
```
