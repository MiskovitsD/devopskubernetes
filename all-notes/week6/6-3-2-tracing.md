# Prepare the application

We will use an open source specification, OpenTelemetry to send tracing data to our tracing component.

For that we will need a Java agent that will be attached to our running process.

Modify the API application's Docker image:

```Dockerfile
ADD --chown=1001 https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v1.20.2/opentelemetry-javaagent.jar opentelemetry.jar
COPY --chown=1001 target/*.jar app.jar
ENTRYPOINT [ "sh", "-c" ]
CMD ["java -javaagent:/opt/app/opentelemetry.jar $JAVA_OPTS -jar app.jar"]
```

We can see an example here, how can we download a file from the internet during an image build.

Try and build: `docker build -t test .`

The DB application's image has no difference, copy this there. Push both.

The Chart will need additional environment variables:

```yaml
          - name: OTEL_SERVICE_NAME
            value: {{ include "spring-cubix.fullname" . }}
          - name: OTEL_EXPORTER_OTLP_ENDPOINT
            value: {{ required "OpenTelemetry target URL is required!" .Values.openTelemetry.targetUrl }}
          - name: OTEL_METRICS_EXPORTER
            value: none
```

Service name is for display purposes. Endpoint is where the tracing data will be sent to. Metrics exporting is not necessary now (OpenTelemetry supports that too).
Note that the application will start slower this way: increase the Pod's startupProbe failureThreshold to 10.

The default values.yaml should have a `openTelemetry: {}` to avoid nil pointers.

The api.yaml and db.yaml should have this:

```yaml
openTelemetry:
  targetUrl: http://tempo.tools:4317
```

We use Grafana Tempo that is running in the tools namespace.

Push all of these and wait with watch.

# Try out Grafana Tempo

Call the store endpoint twice: once with failure, once with success.

Open logs in Grafana. We will see, that we have now a trace_id field in the JSON. 
And because the configuration of Grafana is correct, this will be a link to Tempo, open it.

We can see the main points of the call, when did the control flow change, data was passed. We can see extension data, and running time.

Search for this: http.status_code=500

We can see the failed call, and the exception that happened.
