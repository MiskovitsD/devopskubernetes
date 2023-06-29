# Video

A video for showing the installation and the checking is available. Below you can see a written version of this 
(including links and other useful items to copy-paste).

# Requirements
For the fourth week’s exercises the following steps must be done before the start:
* It is required to still have the same hosts file setting as previously
* Delete the previous Kubernetes cluster with: `kind delete cluster`
  * We do this so we have a clean, fresh state
* Create the new cluster the same way as seen previous week (also check it the same way)
* Create a namespace different from the `default`, and set it as a default for the kubectl
  * `kubectl create namespace home`
  * `kubectl config set-context --current --namespace=home`
  * Check with `kubectl get all` - you should get a message, like "No resources found in home namespace"
* Two scripts were provided to run into the cluster - open a terminal in the folder for your platform (under /requirements/scripts/4-1-setup-tools)
  * Has different scripts for [Windows](/requirements/scripts/4-1-setup-tools/windows) and [MacOS/Linux](/requirements/scripts/4-1-setup-tools/macos-linux) - use the appropriate one for your system
  * the `dependencies` must be run only if it was never run before (but running it multiple times do no harm)
  * the `install` one will setup everything needed in our cluster
* Wait a few minutes. The tools must be set up manually, follow these instructions:
  * go to this URL: http://grafana.cubix.localhost:8080 and enter with `admin` as both username and password (you can skip credentials change)
  * go to this URL: http://grafana.cubix.localhost:8080/datasources (or down on the left Configuration/Data sources)
  * Add data source: Prometheus
    * URL: `http://prometheus-kube-prometheus-prometheus:9090`
    * no other setting needed, click on Save & Test (should display it is working) then Back
  * Still on add data source screen: Loki
    * URL: `http://loki:3100`
    * no other setting needed, click on Save & Test (should display it is working) then Back
  * Still on add data source: Tempo
    * URL: `http://tempo:3100`
    * Trace to logs section: Data source: Loki
    * no other setting needed, click on Save & Test then Back
  * Cancel (go back to the data sources listing)
  * Modify the Loki data source
    * Derived fields, Add
      * Name: `TraceID`
      * Regex: `"trace_id":"([\w\d]*)"`
      * Query: `${__value.raw}`
      * Internal link: Tempo
    * Save & Test (should display it is working)

# Checking if everything is fine
* Under /requirements/scripts/4-2-check-tools there are scripts for both [Windows](/requirements/scripts/4-2-check-tools/windows) and [MacOS/Linux](/requirements/scripts/4-2-check-tools/macos-linux) - open a terminal in the folder appropriate for your platform
* The `deploy` script will deploy a test application to the cluster, run it
* Wait about 2 minutes. The `test` script will call the test application, run it
  * Keep trying if it still replies with 503 or 500 error codes. If it is still not good after 5 minutes, please reach out to me.
* see this URL: http://grafana.cubix.localhost:8080/explore
  * first, choose Prometheus and `application_ready_time_seconds` - you should see a chart
  * second, choose Loki and have labels set like this: `instance=webinar` and `app!=postgresql` - you should see some log rows below
  * finally, click on the last log, there will be an ID-like string, with a Tempo button beside it - click on it - you should see a chart
* Run the `undeploy` script, which will clean up this test application
