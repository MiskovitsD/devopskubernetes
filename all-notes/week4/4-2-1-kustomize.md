# Namespaces

Do we know our current namespace? There is always a context in the background of our kubectl commands, including cluster, namespace and user.

We can check what we have now: `kubectl config view --minify` - there is no namespace set, so we are working with the default namespace.

Create a new namespace: `kubectl create namespace home`

Switch to this namespace with our current context: `kubectl config set-context --current --namespace=home`

Check the config again.

# Simple Kustomize structure

Download the 3 starter files - these are the modified versions from the previous exercise. Copy in a working folder.

Create a kustomization.yaml file, and set up the resources:

```yaml
resources:
- deployment.yaml
- service.yaml
- ingress.yaml
```

We can render what will be sent to the cluster: `kubectl kustomize .` - useful for debugging.

Similar: `kubectl apply --dry-run=server -k .` - this will send the resources to the server and check with that.

Run it: `kubectl apply -k .`

Call it: http://localhost:8080/test

Delete: `kubectl delete -k .`

# Kustomize helps - namespaces

Create a new namespace: `kubectl create namespace kustom`.

In kustomization.yaml we can define the namespace, without writing it to all the resources:

```yaml
namespace: kustom
```

Try it with rendering: `kubectl kustomize .` - there are the namespaces.

Which namespace are we in?˙ `kubectl config view --minify` Run it: `kubectl apply -k .`

If we use `kubectl get pods` we can see, that there is nothing! But if we take a look at the other namespace: `kubectl get pods -n kustom`

Call it.

Delete it: `kubectl delete -k .` - there is no need to specify the namespace, as it is in the kustomization.yaml.

# Kustomize helps - labels

The same can be done with labels, including in selectors!

In kustomization.yaml under a commonLabels:

```yaml
commonLabels:
  app: example
```

Delete the labels from the original resource descriptors. Ingress has 1, Service has 2, Deployment has 3 locations.
Also apply an extra label on Deployment, so we can check, that extra labels will remain:

```yaml
  labels:
    example-label: remains
```

Render: `kubectl kustomize .`, 
run: `kubectl apply -k .`, 
check Pods: `kubectl get pods -n kustom`, 
call: http://localhost:8080/test, 
delete: `kubectl delete -k .`.

The same can be also done with annotations.

# Patching

Fields can be overwritten or resources can be extended with the help of patches.

Copy the deployment.yaml file, and delete everything except the identifiers and the replica count. That should be increased:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example
spec:
  replicas: 2
```

Put this file in the patch list of kustomization.yaml:

```yaml
patches:
- path: patch-replicacount.yaml
```

Render: `kubectl kustomize .`, 
run: `kubectl apply -k .`, 
check Pods: `kubectl get pods -n kustom`, 
call: http://localhost:8080/test, 
delete: `kubectl delete -k .`.

# Patching more complicated

During patching, Kustomization will use a merging strategy. For this, it needs identifiers/metadata to be available.

Copy the deployment.yaml again, this time we will change the image. The container name must remain also:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example
spec:
  template:
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
```

Put this to the list of patches.

Render: `kubectl kustomize .`, 
run: `kubectl apply -k .`, 
check Pods: `kubectl get pods -n kustom`, 
call: http://localhost:8080 , 
delete: `kubectl delete -k .`.

# Patching in kustomization.yaml

Changing the image is a frequent use-case, this can be done directly in the kustomization.yaml file. Delete the patch file and the list entry.

Set up with images, so it will replace ALL the image references:

```yaml
images:
- name: nginxdemos/hello
  newName: nginx
  newTag: 1.14.2
```

Render: `kubectl kustomize .`, 
run: `kubectl apply -k .`, 
check Pods: `kubectl get pods -n kustom`, 
call: http://localhost:8080 , 
delete: `kubectl delete -k .`.

# Operate with configuration files

We can mount externally added files with the help of ConfigMaps and Secrets. 
We will talk about these at our next session, but we will try out the ConfigMap, as Kustomize helps with that - updating these files are not trivial.

Create a folder called content, and insert an example file into it (hello.txt).

Put configMapGenerator into kustomization.yaml:

```yaml
configMapGenerator:
- name: content
  files:
  - content/hello.txt
```

Create a new patch for the deployment again - this time we will not modify, but add new fields to it: volume and volumeMount similarly to what we done earlier:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example
spec:
  template:
    spec:
      containers:
      - name: nginx
        volumeMounts:
        - name: content-volume
          mountPath: /usr/share/nginx/html
      volumes:
      - name: content-volume
        configMap:
          name: content
```

Add this to the list of patches in kustomization.yaml.

Render this `kubectl kustomize .`. We can see, that the ConfigMap will have a unique identifier. 
This is used for triggering new Deployment version rollout if the content of the ConfigMap changes.

Run: `kubectl apply -k .`, 
check Pods: `kubectl get pods -n kustom`, 
call: http://localhost:8080/hello.txt

With `kubectl get replicaset` we can see there is one version now. Change the contents of hello.txt. 
Render - the ConfigMap has a different name now. Run, check Pods, call.

With `kubectl get replicaset` we can see there are two versions now.
Use `kubectl rollout undo` so we will have the unmodified version. Run, check Pods, call, delete: `kubectl delete -k .`.

Note, that the configMapGenerator has multiple arguments, one of them turns this identification off. 
There is a similar option with secretGenerator.

Note, that if we take a look at `kubectl get configmap` we can see, that these were not deleted! 
Delete them by label: `kubectl delete cm -l app=example`.

# Overwrite a list with patching

Now we want to enable reaching only the hello.txt as a path, so we need to patch the Ingress's list of rules.

This however is a list - what will happen, if we create a patch for that list?

The patch should contain the previous rule, but having a different path and pathType.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example
spec:
  rules:
  - http:
      paths:
      - path: /hello.txt
        pathType: Exact
        backend:
          service:
            name: example
            port:
              name: web
```

Add this to the list of patches in kustomization.yaml.

Render this `kubectl kustomize .`. We can see, that the whole paths list was overwritten.

Run: `kubectl apply -k .` (don't worry about the warning), 
call: http://localhost:8080/hello.txt

# Patch a list with JsonPatch

How can it be done, to not overwrite the whole list, but add new entries to it? The original merge strategy does what we had.

For complete freedom, we must use JsonPatches. This is a direct modification of a descriptor.

Change the previous file:

```yaml
- op: add
  path: /spec/rules/0/http/paths/-
  value:
    path: /hello.txt
    pathType: Exact
    backend:
      service:
        name: example
        port:
          name: web
```

This will be added as a different type of patch in the kustomization.yaml:

```yaml
patchesJson6902:
- path: patch-ingress.yaml
  target:
    group: networking.k8s.io
    version: v1
    kind: Ingress
    name: example
```

Render this `kubectl kustomize .`. We can see, that this time the element was added to the list.

Run: `kubectl apply -k .`, 
call: http://localhost:8080/hello.txt and http://localhost:8080

# Kustomize structure

After these small capabilities of Kustomize, time to use the main feature: create variants.

What we want to achieve, is to have two different environments:
* the first, dev environment will use the previous Nginx image, which writes out the used path, server name, etc.
* the second, test environment will use the simpler Nginx image, which simply serves content, which is our hello.txt

First of all, delete the previous namespace and create two new namespaces:

```shell
kubectl delete namespace kustom
kubectl create namespace kustom-dev
kubectl create namespace kustom-test
```

Recommended structure:
* base folder: the common descriptors should lay here
* overalys folder: the variants' unique descriptors should lay here

So, what is common in our use case:
* kustomization.yaml: includes the resources and the labels
* Deployment and Service

Create the base folder, and put these files into them.

The test environment is more similar to what we have now, so start with that. Create an overlays/test folder.

This will have a dedicated Ingress object (patching is unnecessary).

The kustomization.yaml must have a bases section, what this overlay is based on:

```yaml
bases:
- ../../base
namespace: kustom-test
resources:
- ingress.yaml
images:
- name: nginxdemos/hello
  newName: nginx
  newTag: 1.14.2
patches:
- path: patch-replicacount.yaml
- path: patch-volume.yaml
configMapGenerator:
- name: content
  files:
  - content/hello.txt
```

It also should have the patch for the replica count, the volume, and the image setting and namespace setting (for kustom-test).

Now create the overlays/dev folder. It will have the original Ingress. Kustomization.yaml:

```yaml
bases:
- ../../base
namespace: kustom-dev
resources:
- ingress.yaml
```

Render both of these:

```shell
kubectl kustomize overlays/dev
kubectl kustomize overlays/test
```

Deploy:

```shell
kubectl apply -k overlays/dev
kubectl apply -k overlays/test
```

Call:

```
http://localhost:8080/dev
http://localhost:8080/hello.txt
```

We are done, delete the two namespaces:

```shell
kubectl delete namespace kustom-dev
kubectl delete namespace kustom-test
```

Note that this overlaying can be done however deep we would like to.

