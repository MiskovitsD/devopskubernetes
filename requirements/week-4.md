# Requirements
For the fourth week’s exercises the following steps must be done before the start:
* It is required to still have the same hosts file setting as previously
* Delete the previous Kubernetes cluster with: `kind delete cluster`
  * We do this so we have a clean, fresh state
* Create the new cluster the same way as seen previous week (also check it the same way)
* TODO two scripts were provided to run into the cluster
  * the first one must be run only if it was never run before (but running it multiple times do no harm)
  * the second one will setup everything needed in our cluster
* The tools must be set up manually, follow these instructions:
  * go to this URL: http://grafana.cubix.localhost:8080 and enter with `admin` as both username and password (you can skip credentials change)
  * go to this URL: http://grafana.cubix.localhost:8080/datasources (or down on the left Configuration/Data sources)
  * Add data source: Prometheus
    * URL: http://prometheus-kube-prometheus-prometheus:9090
    * no other setting needed, click on Save & Test then Back
  * Still on add data source screen: Loki
    * URL: http://loki:3100
    * no other setting needed, click on Save & Test then Back
  * Still on add data source: Tempo
    * URL: http://tempo:3100
    * Trace to logs - Data source: Loki
    * no other setting needed, click on Save & Test then Back
  * Cancel (go back to the data sources listing)
  * Modify the Loki data source
    * Derived fields, Add
      * Name: TraceID
      * Regex: trace_id=(\S*)
      * Query: ${__value.raw}
      * Internal link: Tempo
    * Save & Test

# Checking if everything is fine
* TODO a script is provided which will deploy an application to the cluster
* a second script will call the test application - wait around 2 minutes before running it
* see this URL: http://grafana.cubix.localhost:8080/explore?orgId=1&left=%7B%22datasource%22:%22ug0IUCs4k%22,%22queries%22:%5B%7B%22refId%22:%22A%22,%22expr%22:%22application_ready_time_seconds%22,%22range%22:true,%22editorMode%22:%22builder%22%7D%5D,%22range%22:%7B%22from%22:%22now-15m%22,%22to%22:%22now%22%7D%7D - you should see values and a chart
* see this URL: http://grafana.cubix.localhost:8080/explore?orgId=1&left=%7B%22datasource%22:%228ukDUCy4z%22,%22queries%22:%5B%7B%22refId%22:%22A%22,%22expr%22:%22%7Binstance%3D%5C%22webinar%5C%22,%20app%21%3D%5C%22postgresql%5C%22%7D%20%7C%3D%20%60%60%22,%22queryType%22:%22range%22,%22editorMode%22:%22builder%22%7D%5D,%22range%22:%7B%22from%22:%22now-15m%22,%22to%22:%22now%22%7D%7D - you should see logs without errors
* click on the last log, there is a detected field called TraceID that has an external link for Tempo, click it - you should see a figure
* clean up everything with the provided script
