# Enter Grafana

For testing, probably you have already visited the Grafana: http://grafana.cubix.localhost:8080
It is capable of showing logs, metrics, traces in a visual form.

Enter, left Explore, switch to Loki.

# Filter for logs

One can filter for logs based on labels. These labels are not the same, as we use on Kubernetes. What we care about now:
* app - the name of the Helm Chart will be seen here
* container - the name of the container
* instance - also for differentiating between api and db
* namespace
* pod - looking for an exact Pod
* stream - stdout or stderr

A good start: namespace=xubix and app=spring-cubix. Thus we will have all the logs from our Spring applications. Run the query.

We can see with a little figure, how many logs were created in time windows, and the logs themselves too.

The last 2 rows: one from MessageController (api app's REST API), the other is from TrainingController (db app's REST API).
With this view we can see how the applications communicated.

Open the row of TrainingController. We can see other data as well about this log event.

# Free word search

In the text field enter MessageController - only those rows will be shown that has this text.

# Aggregating

In the Operations menu we can see multiple additional possibilities. The results can be processed, aggregated, do mathematical operations, statistics.

For example: `rate[1m]` will show how many logs were generated per minute per Pod.

Add a Sum by instance, and like this we will have this not per Pod, but per application.

If we want to search, indexing can help, and we can help the indexing.

# Structured logging in the application

Our application may log in a structured way.

Also if we have an error - send an empty message for store endpoint and take a look at Grafana - 
we will see that the stack trace's lines are not correlated. But in a structure we dont have this problem.

Also this adds another requirement: have logging with 1 row per event.

Typical solution is logging in JSON. This can be done in any application or logging framework. Some support it out of the box (like Quarkus or ASP.NET Core),
some require external libraries. Spring Boot requires one, but its not complicated.

Update pom.xml:

```xml
        <dependency>
            <groupId>net.logstash.logback</groupId>
            <artifactId>logstash-logback-encoder</artifactId>
            <version>7.3</version>
            <scope>runtime</scope>
        </dependency>
```

Add a logback-spring.xml file (downloadable) to the API app: src/resources/logback-spring.xml.

Start it locally. We can see that each log event is a JSON. DB is not running locally, try and call the store locally. 
The stack trace is in JSON and in one line.

Note however, that if we take a look at the logs like this, then the raw readability is now worse: because of JSON's syntax and because of the `\n` signs.
Because of this, in local environment most of the time this is disabled, and only starting from integrated environments is this set up.

Push the changes, and do the same and push for the DB application. Wait for the Actions pipeline to finish.

# JSON logs in Grafana

As no YAMLs changed, only the source image, manually has to be a rollout started.

In a real life environment, the image's tag would have probably changed (version change).

Start a `kubectl get pods -w -n cubix`

Manual rollout: `kubectl rollout restart deploy/api-spring-cubix -n cubix` and `kubectl rollout restart deploy/db-spring-cubix -n cubix`

When the rollout is completed, call the application. Check the logs, we can see the JSONs! We can put on a JSON parser.

Call the app with an error. Check the logs. We can see that the stack trace is in one log event.
