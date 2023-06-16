# Tutorial image with script

```
quay.io/drsylent/docker-tutorial:script
```

# Image you built during the last exercise (replace the USERNAME placeholder)

```
ghcr.io/USERNAME/cubix/cloudnative/demo:actions
```

# Postgres environment variables

```
-e POSTGRES_USER=user -e POSTGRES_PASSWORD=password
```

# Spring Boot database environment variables

```
-e SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/postgres -e SPRING_DATASOURCE_USERNAME=user -e SPRING_DATASOURCE_PASSWORD=password
```

# Spring Boot database example image

```
quay.io/drsylent/cloud-native-db-demo:springboot3
```

# Database example URL

http://localhost:8080/visit
