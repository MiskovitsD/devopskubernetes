# Fork the Spring Boot example repository.

# Compile, package, start and test the application.

```shell
./mvnw clean package
./mvnw verify
java -jar .\target\cubix-cloudnative-spring-demo-0.0.1-SNAPSHOT.jar
```

Import into Postman/Bruno and call the application.

# Prepare a GitHub Actions pipeline/flow that creates a binary

Before setting up, replace the placeholders in `maven-settings.xml` and `pom.xml` (3 locations!). Commit & push.

Click on Actions. Choose Publish Java Package with Maven. Open the referenced tutorial for showcasing and the README.

We have a YAML file. In Documentation we can see how to set up for triggering on main branch push:

```yaml
on:
  push:
    branches: [ main ]
```

Set up caching:

```yaml
      with:
        java-version: '17'
        distribution: 'temurin'
        server-id: github # Value of the distributionManagement/repository/id field of the pom.xml
        cache: 'maven'
```

Include in the YAML:

```shell
java -version
```

Switch `package` to `verify` for running ITs.

Commit all the changes.

# Check on the pipeline run - run the result locally

Download the JAR from Packages. Start again with `java -jar`. Call with Postman.
