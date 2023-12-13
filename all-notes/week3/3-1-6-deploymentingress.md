# Deploy Nginx with the help of Deployment

Create a Deployment YAML, based on this: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#creating-a-deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

Deploy it with kubectl: `kubectl apply -f <location>`

Create a Service - this can be done not just with a YAML and create Service command, but with an expose command, which will set the selector up for us:
`kubectl expose deployment/nginx --port=80 --target-port=80`

Check the created Service: `kubectl describe svc/nginx` The label should be also there (app=nginx).

Port forward it and check: `kubectl port-forward svc/nginx 9080:80` http://localhost:9080

# Use an Ingress to reach the application

Create an Ingress from the example: https://kubernetes.io/docs/concepts/services-networking/ingress/#the-ingress-resource

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
```

Apply it `kubectl apply -f <>`, and try it out (we created our cluster with exposure to the 8080 port): http://localhost:8080

Our cluster uses Nginx as Ingress implementation. It has annotation for rewriting the target path, try this out:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx
  labels:
    app: nginx
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /test
        pathType: Exact
        backend:
          service:
            name: nginx
            port:
              number: 80
```

Try it out: http://localhost:8080/test - we should see, that this redirected us to the root path from the container's point of view.

Revert the change (Remove annotation, path to / and pathType to Prefix). Try again the previous endpoint, we should see the difference.

# Use an init container

Define an init container in the Deployment, that writes to a file system, that the Nginx will be able to use.

We have not talked about volumes yet, but we can do something similar as we have done with Docker.
Create a volume, where the init container will write to (mounting), and then mount it to the "main" container.
EmptyDir is the type of the volume - this is a temporary location handled by the Kubernetes, that lives until the Pod lives.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      initContainers:
      - name: prepare-content
        image: busybox:1.28
        command: ['sh', '-c', 'echo Hello > /tmp/target/hello.txt']
        volumeMounts:
        - mountPath: /tmp/target
          name: content-volume
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
        volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: content-volume
      volumes:
      - name: content-volume
        emptyDir: {}
```

Before applying, start a: `kubectl get pods -w`.
Apply this: `kubectl apply -f <location>`. Take a look at how the existing Pod will not be deleted immediately, and that the Init phase can be seen.

Check the result: http://localhost:8080/hello.txt

# History

Check what happened in the background: `kubectl get replicaset` - we can see 2. Check the history of the deployment: `kubectl rollout history deploy/nginx`.

Rollback to the original version: `kubectl rollout undo deploy/nginx`. Check again the hello.txt.

Check again the ReplicaSets: `kubectl get replicaset`. Check the history with revision numbers: `kubectl rollout history deploy/nginx --revision`

Do a rollback again, with a direct revision number: `kubectl rollout undo deploy/nginx --to-revision=0`.

Check again the hello.txt.

# Set the same up with the help of kubectl, without YAMLs

Delete only the Deployment and the Ingress: `kubectl delete deployment/nginx ingress/nginx`.

Create a Deployment with the help of kubectl: `kubectl create deployment nginx --image=nginxdemos/hello:plain-text --port=80`.

Create an Ingress with the help of kubectl: `kubectl create ingress nginx --rule=/*=nginx:80)`.

There will not be any labeling automatically on these, so put them manually: `kubectl label deploy/nginx app=nginx` and `kubectl label ingress/nginx app=nginx`.

Check again: http://localhost:8080

# Scale the application

Scale up to 3 with the help of edit: `kubectl edit deploy/nginx`. 
Check that there will be no new rollouts: `kubectl rollout history deploy/nginx`. 
Check that we have 3 pods: `kubectl get pod`.

Call multiple times, the round robin algorithm should be seen.

Scale down with kubectl to 2: `kubectl scale deploy/nginx --replicas=2`. Check: `kubectl get pod`.

# Ingress path matching

Change the Ingress so that only one endpoint can be reached: `kubectl edit ingress/nginx`. Path: /test pathType: Exact

Check: http://localhost:8080/test

Check that there are no responses for other paths: http://localhost:8080 http://localhost:8080/no http://localhost:8080/test2 http://localhost:8080/test/no

Change the Ingress so that with /test prefix everything can be reached: `kubectl edit ingress/nginx`. Path: /test pathType: Prefix

Check: http://localhost:8080/test http://localhost:8080/test/yes

Check that there are no responses for other paths: http://localhost:8080 http://localhost:8080/no http://localhost:8080/test2
