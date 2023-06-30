# ConfigMap data section

```
{{ (.Files.Glob (print .Values.configMap.directory "/*")).AsConfig | indent 2 }}
```

# DB application URL setting for API application

```
api.message.url=http://db-spring-cubix:8080
```

# DB application configuration setting

```
spring.datasource.url=jdbc:postgresql://postgresql:5432/postgres
spring.datasource.username=user
```
