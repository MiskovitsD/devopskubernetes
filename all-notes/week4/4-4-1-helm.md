# Start with a new Chart

Start by creating a new namespace to work with: `kubectl create namespace helm-app`.

Create a new Helm Chart in our working folder: `helm create tutorial`. We should take a look at what we have.

Customize it:
* deployment.yaml: take out the probes and set the port for 8080
* service.yaml: delete type (the default ClusterIP will be used always)
* ingress.yaml: OK
* hpa.yaml and serviceaccount.yaml are not interesting for us (will not be deleted)
* Chart.yaml check
* values.yaml: image and ingress host change

```yaml
image:
  repository: ghcr.io/drsylent/cubix/cloudnative/demo:actions
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: "demo"
```

```yaml
ingress:
  enabled: true
  className: ""
  annotations: {}
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  hosts:
    - host: application.cubix.localhost
      paths:
        - path: /
          pathType: Prefix
```

This can be rendered similiarly to Kustomize: `helm template tutorial .`.

Install it: `helm install tutorial . -n helm-app`

Call it: http://application.cubix.localhost:8080/demo/message

See what can we check with the Helm CLI:

```shell
helm list -n helm-app
helm get all tutorial -n helm-app
```

# Deploy a database with the help of Helm

There are remote reopsitories, from which one can deploy Charts. One of the most popular ones is Bitnami. 
Add their repository to our known ones: `helm repo add bitnami https://charts.bitnami.com/bitnami`

For each chart, it is a legit question: how can we customize it, what kind of values can we set?
For this Chart: https://github.com/bitnami/charts/tree/main/bitnami/postgresql/ - or we can use the CLI: `helm show values bitnami/postgresql`

Create a separate folder, and put in a values.yaml file. We can see, that the auth part is the most important, we have to fill:

```yaml
auth:
  username: user
  password: password
  database: postgres
```

Create a dedicated namespace for the database: `kubectl create namespace helm-db`

Deploy the database: `helm install postgres bitnami/postgresql -n helm-db -f values.yaml`

Check it with: `kubectl get pods -w -n helm-db` - the Pods are ready, when a client can connect to the DB.

In the background, the Chart created a PVC, check it out: `kubectl get pvc -n helm-db`
Check it in more detail, as we will not create a PVC during our training: `kubectl get pvc/data-postgres-postgresql-0 -n helm-db -o yaml`

We can see, there are Helm-related labels, check that these are created for our Chart as well,
with: `kubectl get deploy/tutorial -n helm-app -o yaml`.

# Switch the application image

Now that we have a database, we can start an application, that uses database.

Change the image in values.yaml:

```yaml
image:
  repository: quay.io/drsylent/cloud-native-db-demo
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: "springboot3"
```

Add environment variables to our Deployment:

```yaml
          env:
          - name: SPRING_DATASOURCE_URL
            value: jdbc:postgresql://postgres-postgresql.helm-db:5432/postgres
          - name: SPRING_DATASOURCE_USERNAME
            value: user
          - name: SPRING_DATASOURCE_PASSWORD
            value: password
```

We can communicate with different namespaces, we can see the address.

Also, the name what we have to reach can be retrieved like this: `helm get values postgres -n helm-db`

Deploy our change: `helm upgrade tutorial . -n helm-app`

Call it: http://application.cubix.localhost:8080/visit

# Try out rollbacking

We can see the history: `helm history tutorial -n helm-app`

Rollback is similar to how we did with the Deployment: `helm rollback tutorial -n helm-app`

Call the previous simple endpoint: http://application.cubix.localhost:8080/demo/message

Check the history again. We can see, that unlike the Deployment, we will have a new revision because of this.

Rollback with the direct revision number: `helm rollback tutorial 2 -n helm-app`

Check the history again - now we have 4 revisions.

# Create templates for the envionrment variables

The environment variables should be modifiable easily.

We can see how we can retrieve a value from the values.yaml file, for example {{ .Values.replicaCount }}

```yaml
          env:
          - name: SPRING_DATASOURCE_URL
            value: jdbc:postgresql://{{ .Values.db.instanceName | default "postgres" }}-postgresql.{{ .Values.db.namespace }}:5432/{{ .Values.db.database }}
          - name: SPRING_DATASOURCE_USERNAME
            value: {{ .Values.db.username }} 
          - name: SPRING_DATASOURCE_PASSWORD
            value: {{ .Values.db.password }}
```

Try and deploy it like this: `helm upgrade tutorial . -n helm-app` - nil pointer! 
The .Values.db is null, so we'll have nil pointers here, invalid references.

Put in simply an empty db object in the values.yaml file:

```yaml
db: {}
```

Try and deploy again. It works now, but... what about the values? `helm get all tutorial -n helm-app` - everything is empty...

Check the state of the Pods: `kubectl get pods -n helm-app` - we can see that it is crashing and restarting.
Roll back to the previous good state: `helm rollback tutorial -n helm-app`

Try and eliminate this possibility. We have a template option, called Required. This will check the incoming value:

```yaml
          env:
          - name: SPRING_DATASOURCE_URL
            value: jdbc:postgresql://{{ .Values.db.instanceName | default "postgres" }}-postgresql.{{ required "Namespace of database is required!" .Values.db.namespace }}:5432/{{ required "Name of database is required!" .Values.db.database }}
          - name: SPRING_DATASOURCE_USERNAME
            value: {{ required "Username of database is required!" .Values.db.username }} 
          - name: SPRING_DATASOURCE_PASSWORD
            value: {{ required "Password of database is required!" .Values.db.password }}
```

Comment out the db section in values.yaml and try and deploy it again. Still null pointer... This will not eliminate null pointers.

Talk a bit about, how we can have a values.yaml file in the Chart itself, but we can also add one outside the Chart (what we had with the DB).
Remove the commenting of the db, and outside the Chart, create a new empty values.yaml file.

Deploy with that: `helm upgrade tutorial tutorial -n helm-app -f values.yaml` - still empty, but no null pointer failure, as the values file in the Chart is also acknowledged!

Add all the original values to our new values.yaml file (except what we have defaulted):

```yaml
db:
  namespace: helm-db
  database: postgres
  username: user
  password: password
```

Call it: http://application.cubix.localhost:8080/visit

# If there is no namespace, use the more simple URL

We can do this simply with an if-else:

```yaml
          - name: SPRING_DATASOURCE_URL
            {{ if not .Values.db.namespace }}
            value: jdbc:postgresql://{{ .Values.db.instanceName | default "postgres" }}-postgresql:5432/{{ required "Name of database is required!" .Values.db.database }}
            {{ else }}
            value: jdbc:postgresql://{{ .Values.db.instanceName | default "postgres" }}-postgresql.{{ .Values.db.namespace }}:5432/{{ required "Name of database is required!" .Values.db.database }}
            {{ end }} 
```

Delete the namespace value from the values.yaml and ender it: `helm template tutorial tutorial -n helm-app -f values.yaml` -
we can see that there are empty lines. They can be removed with `{{-` instead of `{{`

As we do not need the name of the namespace if we are in the same namespace as the target Service,
make it so, that we use a more simple URL if the target namespace and the namespace in the values.yaml are the same.

There are metadata available for our current context: https://helm.sh/docs/chart_template_guide/builtin_objects/ - 
we can use .Release.Namespace for retrieving the namespace we are targeting with our deployment.

Do it like this: `{{- if or (not .Values.db.namespace) (eq .Values.db.namespace .Release.Namespace) }}` - 
be very careful about the brackets.

Render it. It will fail due to the empty namespace. With this templating language there is no short circuiting.

Solutions (default or toString):

```yaml
{{- if or (not .Values.db.namespace) (eq (default "" .Values.db.namespace) .Release.Namespace) }}
{{- if or (not .Values.db.namespace) (eq (.Values.db.namespace | toString) .Release.Namespace) }}
```

Try it out with a namespace setting now for helm-app, render it. Seems fine.

For testing purposes, deploy a database to this namespace too (watch for the current directory):

```shell
helm install postgres bitnami/postgresql -n helm-app -f values.yaml
helm update tutorial tutorial -n helm-app -f values.yaml
```

Call it. You should see a value of 1.

Roll back: `helm rollback tutorial -n helm-app`. Call it. A different value should be seen. 
Also change back the values.yaml file.

Delete the database: `helm uninstall postgres -n helm-app` Check: `kubectl get all -n helm-app` Seems fine...

PVCs are not shown: `kubectl get pvc -n helm-app`. We can see, that the PVC is still there. The Chart does not delete it automatically.

Also, check for the PV behind it: `kubectl get pv` - these are namespace-independent.

Delete the PVC: `kubectl delete pvc/data-postgres-postgresql-0 -n helm-app` Check the PV, now gone.

# Modify template where we can add custom environment variables

We will use another directive: range. This is essentially a for-each, will go through each element.

What we want, is to have an env section in values.yaml, and will have objects as list, with a name and a value:

```yaml
          {{- range .Values.env }}
          - name: {{ .name }}
            value: {{ .value }}
          {{- end }}
```

Render it: `helm template tutorial tutorial -n helm-app -f values.yaml`

Add to our values.yaml file:

```yaml
env:
- name: SPRING_MAIN_BANNER-MODE
  value: off
```

Render it, seems fine. Deploy it: `helm update tutorial tutorial -n helm-app -f values.yaml`.
It seems like our value was handled as a logical value of false... In Go, "off" means "false"!

Try and put the off into quotation marks. Deploy - not good.

What we want to have, is that the template will have quotation, whatever happens. We have a directive for this: `value: {{ .value | quote }}`

Render it: we can see even here, that it will be good! Deploy it, and check the logs: `kubectl logs ... -n helm-app`
What we did is that we turned off the startup Spring Boot message.

# Automatically deploy the database with the application

Delete the application and the database, with its namespace:

```shell
helm uninstall tutorial -n helm-app
helm uninstall postgres -n helm-db
kubectl delete namespace helm-db
```

Add the Postgres Chart as dependency to the Chart.yaml:

```yaml
dependencies:
- name: postgresql
  version: "12.1.9"
  repository: "https://charts.bitnami.com/bitnami"  
```

For the actual version, we can take a look at: `helm show chart bitnami/postgresql` (optional: `helm repo update`)

All our previous Postgresql values.yaml values must be entered to our values.yaml now, under the name of the Chart:

```yaml
postgresql:
  auth:
    username: user
    password: password
    database: postgres
```

The deployment.yaml must be modified, we will not have the db values, 
instead the postgresql.auth must be used, 
also instanceName will be replaced by .Release.Name:

```yaml
          - name: SPRING_DATASOURCE_URL
            value: jdbc:postgresql://{{ .Release.Name }}-postgresql:5432/{{ required "Name of database is required!" .Values.postgresql.auth.database }}
          - name: SPRING_DATASOURCE_USERNAME
            value: {{ required "Username of database is required!" .Values.postgresql.auth.username }} 
          - name: SPRING_DATASOURCE_PASSWORD
            value: {{ required "Password of database is required!" .Values.postgresql.auth.password }} 
```

Render it: `helm template tutorial tutorial -f values.yaml -n helm-app` we get a strange error.

We must download the dependency beforehand: `helm dependency update tutorial`

Render it - seems alright! Now try and delete the postgresql section from the values.yaml and render it - we have missing required fields.

This time, we should fill it with the help of set: `helm template test tutorial -f values.yaml -n helm-app --set postgresql.auth.database=db --set postgresql.auth.username=user --set postgresql.auth.password=password`

Check that the generated Postgresql Service name is fine for our datasource URL.

Instead of installing it with install, we should install it with a command, that can both install and update:

```shell
helm upgrade tutorial tutorial --install -f values.yaml -n helm-app --set postgresql.auth.database=db --set postgresql.auth.username=user --set postgresql.auth.password=password
```

Call it: http://application.cubix.localhost:8080/visit

Check that everything is in one namespace: `kubectl get all -n helm-app`

# Package our solution

We can package and then distribute our Chart: `helm package tutorial`.

We can pull down with: `helm pull bitnami/postgresql` - with --untar we can untar it instantly.

# Small extras

We should take a small look at:

* tests: we can define custom tests, that will check what we deployed - good for initial deployment, not constant monitoring
* _helpers.tpl: functions can be defined here, that can be re-used

There are also multiple possible options, routines and directives - some of these will be used in our next session.

