# Image to use for starting

Replace the USERNAME with your GitHub account's name in the repository.

This is what I copied initially, 
but the correct way does not have the tag (`actions`) in the repository field, rather
in the tag field at the bottom (where the value is currently `demo`).

```yaml
image:
  repository: ghcr.io/USERNAME/cubix/cloudnative/demo:actions
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: "demo"
```

# Hostname to use

```
application.cubix.localhost
```

# URL for host based Ingress

http://application.cubix.localhost:8080

# Bitnami repository

https://charts.bitnami.com/bitnami

# Bitnami PostgreSQL Chart

https://github.com/bitnami/charts/tree/main/bitnami/postgresql/

# DB image values

```yaml
image:
  repository: quay.io/drsylent/cloud-native-db-demo
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: "springboot3"
```

# Environment variables

```yaml
          env:
          - name: SPRING_DATASOURCE_URL
            value: jdbc:postgresql://postgres-postgresql.helm-db:5432/postgres
          - name: SPRING_DATASOURCE_USERNAME
            value: user
          - name: SPRING_DATASOURCE_PASSWORD
            value: password
```

# Helm built-in objects for metadata

https://helm.sh/docs/chart_template_guide/builtin_objects/

# Environment variable setting for turning of Spring banner

```yaml
env:
- name: SPRING_MAIN_BANNER-MODE
  value: off
```

# Setting values in command line for the database

```shell
--set postgresql.auth.database=db --set postgresql.auth.username=user --set postgresql.auth.password=password
```

