# Prepare the application for metrics pulling

Prometheus will use a pull based model, which will pull metrics from the application itself - 
so we must upgrade the application to publish metrics like these. Example: how many requests have failed.

An application will not publish something like this automatically, we have to use a library for this.
We will use Micrometer, which will integrate into Spring Boot's Actuator. Modify the API application.

pom.xml:
```xml
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-registry-prometheus</artifactId>
            <scope>runtime</scope>
        </dependency>

```

application.properties:

```properties
management.endpoints.web.exposure.include=health,prometheus
```

Start it up, and call: http://localhost:9082/actuator/prometheus We will see many metrics.

Call the application and we will see even more metrics, based on for example the endpoints.

Push the change for the API application and do the same for the DB app.

This is sufficient for automatic metrics - if we want to publish custom metrics, the Micrometer's SDK should have been used.

# Prepare the Helm Chart

Prometheus can be configured multiple ways. 
What we have now, is that it uses a default configuration, and with the help of Kubernetes resources, it can be further modified.

There are 2 resource types good for Prometheus' Service Discovery: PodMonitor and ServiceMonitor.

PodMonitor looks directly for Pods, the ServiceMonitor uses a Service's Service Discovery.
As we have not put the management port in our Service, it can not be used, 
but it wouldn't be a big deal, as that Service port would not be published by the Ingress.

Note that as it uses Kubernetes' Service Discovery, only those Pods will be scraped, that are ready.

Create a PodMonitor:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: {{ include "spring-cubix.fullname" . }}
  labels:
    {{- include "spring-cubix.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "spring-cubix.selectorLabels" . | nindent 6 }}
  podMetricsEndpoints:
  - port: management
    path: /actuator/prometheus
```

Before deploying, note that the Prometheus was configured in a way, that it will monitor only those namespaces, that have a specific label on them:
`kubectl label namespace/cubix monitoring=true`

Deploy it locally: `helm upgrade api spring-cubix -n cubix -f api.yaml --install`

Check the PodMonitor: `kubectl get podmonitor -n cubix`

If okay, push the change, so the DB app will also receive the update.

Note that because the Deployment did not change, manual rollout is needed to use the new image:

```shell
kubectl rollout restart deploy/api-spring-cubix -n cubix
kubectl rollout restart deploy/db-spring-cubix -n cubix
```

Call the application with the store endpoint.

# Try out Prometheus and Grafana

Open Grafana, and in Explore choose the Prometheus now.

Similar to what we had with logging, and we can choose a metric that is interesting to us.

Set up labels for namespace and container, and choose application_ready_time_seconds as metric.

We will see a diagram, how did that value change. If we remove the container label, we will see multiple values.

Choose a different metric: http_server_requests_seconds_count - this will tell, how many times was an endpoint called.

We can see that there were 3 endpoints touched. What if I want to see only one? We can see all the available labels for the time series' below.

Example label: `uri=/training/store` like this we will have only the endpoint on API app. We can also choose operators, so
we can do regex: `uri=~/message/\*` 

Scale up the API app: `kubectl scale deploy/api-spring-cubix -n cubix --replicas=2`

# Aggregate with Prometheus

Call the store endpoint multiple times, sometimes wait a bit in between. Look at the metrics without uri filtering, and with a small time window (5m).

Now try out aggregation, which is the biggest power of Prometheus. Add an operation: rate range 1m
This will give us the per second average number of requests in the last minute.

If we want to see the API apps' metrics summed, give it a sum by container.

Or we can do sum by uri, so we can see that each endpoint was called how many times (call other endpoints too beforehand).

Wait a bit. Call the store 3 times, the message 2 times, the test 1 time and add an Increase 1m operation.
We can see that how many times were each called (note that it might give double values because of extrapolation with small numbers).

# Use other types of metrics than Counters

These were only Counters - values that can go only up (number of requests increase only). There are also gauges, which can go up and down.

An example: how many megabytes of heap memory was consumed by the Pods:
`jvm_memory_used_bytes namespace=cubix area=heap, sum by pod, divide by scalar 1024 (twice)`

A third type is histograms, which are distributed values, like response times: we can tell for example, that 50% of requests had lower response time, then a value.

# Grafana dashboard

Now note, that these queries are used ad-hoc, most of the times they are written for alerts, or if we modify a dashboard.

Dashboards are visual summaries of resources we want to monitor.

We will use a pre-existing, downloadable Spring Boot dashboard that is customized.

Import it, and we can see what this is capable of.

# Alerting

In DevOps it is impossible that one would watch monitors for 24 hours and look for anomalies - 
an automatic process should watch the metrics and if these are outside pre-defined values, then it must notify a personnel.

Alerting can happen multiple ways in multiple forms, most of the time this requires another tool (a popular one is PagerDuty).
With that it can send message to Slack, Microsoft Teams, can send SMS, or can call someone automatically.

Create an alert on Grafana: for 5 minutes this must be active:
`increase(http_server_requests_seconds_count{namespace="cubix", container="api", outcome="SERVER_ERROR"}[1m])`
if sum() is over 3, get an alert.

It can be set, how often to check the state. Also most of the time there is no immediate alerting, but rather a 
PENDING state, when the value is not okay, but waits that maybe it will be back to normal again.
If this does not happen, we will have an alert.

Set it to 10s (check) and 2m (pending).

Give a test name, folder and group. Leave notifications empty.

Save and call the store endpoint with a failure multiple times. After a bit, we will see that we are in PENDING.

If we won't call it again with failures, it will restore to normal, so call again and again.

After a while it will be in FIRING. If we wait without errors, it will be back to NORMAL.


