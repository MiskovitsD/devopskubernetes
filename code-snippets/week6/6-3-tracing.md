# Add OpenTelemetry agent to Docker image

```
ADD --chown=1001 https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v1.20.2/opentelemetry-javaagent.jar opentelemetry.jar
```

# Use OpenTelemetry agent

```
-javaagent:/opt/app/opentelemetry.jar
```

# Helm Chart environment variables for OpenTelemetry

```
          - name: OTEL_SERVICE_NAME
            value: {{ include "spring-cubix.fullname" . }}
          - name: OTEL_EXPORTER_OTLP_ENDPOINT
            value: {{ required "OpenTelemetry target URL is required!" .Values.openTelemetry.targetUrl }}
          - name: OTEL_METRICS_EXPORTER
            value: none
```

# OpenTelemetry values

```
openTelemetry:
  targetUrl: http://tempo.tools:4317
```
