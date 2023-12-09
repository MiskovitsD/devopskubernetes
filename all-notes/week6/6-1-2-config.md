# ConfigMap and Secret

There are two options for storing configuration in Kubernetes.
Both are similar, Secret is for storing sensitive data.
Both store key-value pairs, that can be used as environment variables or as file mounting.

# ConfigMap playground

Dedicated command: `kubectl create configmap --help`

Create a ConfigMap, which has the DB application's application.properties file:
`kubectl create configmap file-test -n cubix --from-file src/main/resources/application.properties --save-config`

Check back: `kubectl describe cm/file-test -n cubix`
We can see, that we could store binary data too.

Sadly updating can be tricky through kubectl. Edit or patch are options. 
A tricky option can be to use a created YAML for applying (but it won't work always):
`kubectl create configmap file-test --from-literal TEST_KEY=TEST_VALUE -n cubix -o yaml --dry-run=client | kubectl apply -f -`

We can see that with this we have our new key-value pair, but the file is deleted - more trickery is needed.

Delete this and re-create from the file.

Try and retrieve a key's value: `kubectl get cm/file-test -n cubix -o jsonpath="{.data.application\.properties}"`

# Secret playground

Dedicated command: `kubectl create secret --help` 
We can see, that not just regular key-value pairs, but TLS certificates and image registry tokens can be used directly.

Create a generic key-value pair type, from the previous file with an example simple value:
`kubectl create secret generic secret-test -n cubix --from-file .\src\main\resources\application.properties  --from-literal TEST_KEY=TEST_VALUE`

Query: `kubectl describe secret/secret-test -n cubix` We can see that describe will not return the value.

What about the raw YAML: `kubectl get secret/secret-test -n cubix -o yaml` We can see that it is there, but Base64 encoded.
All we need is to decode it if it is needed.

Delete both the ConfigMap and the Secret: `kubectl delete cm/file-test secret/secret-test -n cubix`

# ConfigMap in Helm

Sadly, Helm has a bit complicated support for ConfigMaps and Secrets. With Kustomize we have already seen the power of configMapGenerator which was simple.
Helm needs a bit extra work through CD logic.

First, create a template for a ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "spring-cubix.fullname" . }}
  labels:
    {{- include "spring-cubix.labels" . | nindent 4 }}
data:
{{ (.Files.Glob (print .Values.configMap.directory "/*")).AsConfig | indent 2 }}
```

So what is that what we have under the data section?
We will use a value for determining the directory, from which key-values will be read. A /\* will be concatenated to the end of it.
Files.Glob will list files based on a pattern that are inside the Chart's folder.
AsConfig will format it to a YAML. Indenting is needed.

Note that we need this only, if someone needs this. Surround it like this:

```yaml
{{- if .Values.configMap.enabled }}
...
{{- end }}
```

Put this to the Chart's default values.yaml file, so there will be no nil pointers:

```yaml
configMap:
  enabled: false
  directory: configuration
```

# Use the ConfigMap for environment variables

Put this to environment variables:

```yaml
          envFrom:
          - configMapRef:
              name: {{ include "spring-cubix.fullname" . }}
```

This will put all the key-values as environment variables to the Pods. 
It is also an option, to set up an environment variable key, and assign a value to it from one of the ConfigMap's keys.

We will not need this all the time, so surround with conditions:

```yaml
          {{- if and .Values.configMap.enabled (eq .Values.configMap.as "env") }}
          ...
          {{- end }}
```

As a nil value can not be compared to a string, put an empty string into the values.yaml file as a default:

```yaml
configMap:
  enabled: false
  directory: configuration
  as: ""
```

Now test our solution. Our current environment variables come from api.yaml. That one must be copy-pasted to a file.
The name of the file will be used for key, so it must be API_MESSAGE_URL, the content must be the URL.
NOTE: there must be no end line or any other character at the end.

As Helm can work only with files in the Chart's directory, it must be put under a new configuration folder.

The api.yaml file's env part must be deleted, and add this:

```yaml
configMap:
  enabled: true
  as: env
```

Check it before running: `helm upgrade api spring-cubix --install -f api.yaml -n cubix --dry-run` - 
this is also good for checking, what would happen if we run this to the server. Seems fine, run it without dry-run.

Check: `kubectl get pods -w` and call - really is fine.

# Use the ConfigMap for file mounting / volume

As with Docker, we have to define this as a volume too, also we must add the condition:

```yaml
      {{- if and .Values.configMap.enabled (eq .Values.configMap.as "file") }}
      volumes:
      - name: config
        configMap:
          name: {{ include "spring-cubix.fullname" . }}
      {{- end }}
```

Also we must define at the container, where we want to mount this volume:

```yaml
          {{- if and .Values.configMap.enabled (eq .Values.configMap.as "file") }}
          volumeMounts:
          - name: config
            mountPath: /opt/app/config
          {{- end }}
```

This will work, because the application will run in /opt/app folder and Spring Boot checks for a config folder in the running folder.

Create an application.properties file in the configuration folder:

```properties
api.message.url=http://db-spring-cubix:8080
```

Modify the api.yaml file, so that the ConfigMap will be used for file mounting. Check with dry-run, run and call.

# Put this into CD process

Now we have a problem: if we would package and distribute this Helm Chart, we could not put everyone's configuration files 
in the Chart beforehand. But no worries: our CD process will handle the copying.

Move the application.properties file to the root as api.properties and remove the configuration folder.

Create a db.properties file, and have the database setting in that:

```properties
spring.datasource.url=jdbc:postgresql://postgresql:5432/postgres
spring.datasource.username=user
```

Set up the db.yaml file, and delete the corresponding environment variables.

The CD process should do the copying, so modify the GitHub Actions file:

```
          mkdir spring-cubix/configuration
          cp api.properties spring-cubix/configuration/application.properties
          helm upgrade api spring-cubix --install -f api.yaml -n cubix
          cp db.properties spring-cubix/configuration/application.properties
          helm upgrade db spring-cubix --install -f db.yaml -n cubix --set env[0].value="$env:POSTGRESQL_PASSWORD"
          rm -r spring-cubix/configuration
```

Push and check that everything is working fine: watch Pods and call.

# Secret for the application

We do not want to store sensitive data in Git. However we already cheated:
even though the password can not be read from the GitHub Actions logs (because of automatic censorship),
still anyone with permission to use Helm can read it out: `helm get values db -n cubix` or from the Deployment: `kubectl describe deploy/db-spring-cubix -n cubix`

An option can be, to create a Secret via the CD process, and refer to that. But the most secure would be, to not store the password in our CD environment.

An out-of-channel solution is the most recommended, to create and manage the Secret outside our application.
In a public cloud there are options for storing and syncing sensitive values - now we will do it manually.

So all we need now is to have a reference to a pre-existing Secret in our Helm deployment.

Create the Secret: `kubectl create secret generic db-password --from-literal password=Pw1234 -n cubix --save-config`

For handling together, put the same label on that: `kubectl label secret/db-password app.kubernetes.io/instance=db -n cubix`

Update the deployment.yaml. There will be a secret list in our values.yaml file, where 
the environment variable's name, the Secret's name and the relevant key name can be set:

```yaml
          {{- range .Values.secret }}
          - name: {{ .envName }}
            valueFrom:
              secretKeyRef:
                name: {{ .secretName }}
                key: {{ .secretKey }}
          {{- end }}
```

Time to update the db.yaml file:

```yaml
secret:
- envName: SPRING_DATASOURCE_PASSWORD
  secretName: db-password
  secretKey: password
```

Deploy it locally - note that we will need the config file:

```shell
mkdir spring-cubix/configuration
cp db.properties spring-cubix/configuration/application.properties
helm upgrade db spring-cubix --install -f db.yaml -n cubix
rm -r spring-cubix/configuration
```

If everything is fine (pod watch, call), push the changes.
