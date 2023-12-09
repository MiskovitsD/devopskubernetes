# Create a YAML of an Nginx pod

Nginx is a simple web server that can serve.

Create a YAML from an example (without port config): https://kubernetes.io/docs/concepts/workloads/pods/#using-pods

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
```

We can start it via: `kubectl create -f <location>`

Check it: `kubectl get pods` and `kubectl logs nginx`

# Put in a port into the Pod descriptor

Put in a port specification for port 80:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80
```

Apply the change: `kubectl apply -f <location>` - it will fail, as a Pod can be modified in a very limited way.

The resource, that handles pods will delete the existing pod, and will create new ones instead.

We will do the same; delete it first: `kubectl delete nginx`. Check it: `kubectl get pods`.

Now deploy it with apply: `kubectl apply -f <location>`. Check it: `kubectl get pods`.

# Create a Service for this Pod

Copy an existing one as a starting point: https://kubernetes.io/docs/concepts/services-networking/service/#defining-a-service

The name must be remembered (can be the same as the Pod's), label should be something simple, the targetPort should be 80.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

Deploy it with apply: `kubectl apply -f <location>`.

# Test the networking

Do a port forwarding directly with the Pod: `kubectl port-forward pod/nginx 9080:80`. Now check it: http://localhost:9090

Stop it, and do the same with the Service: `kubectl port-forward svc/nginx 9080:80`. Check it again. 
Nothing, due to the label selector - our pod has no labels.

Edit the pod like this: `kubectl edit pod/nginx`. Put in the same label, as the Service has for selector.

```yaml
metadata:
  labels:
    app: nginx
```

Now do the port forwarding with the Service again. It should work now.

# Play with the labels

Now put a new label on the pod, with the help of kubectl: `kubectl label pod/nginx cloud=native`

Try and see the details of the Pod with different commands:

```yaml
kubectl describe pod/nginx
kubectl get pod/nginx -o yaml
kubectl get pod/nginx -o json
kubectl get pod/nginx -o jsonpath=’{.metadata.labels}’
```

We have a helping command for selectors too: `kubectl set selector svc/nginx cloud=native`

Use describe on the Service to see, whether this was an overwrite or a new selector: `kubectl describe svc/nginx`.

Try again with port forwarding and calling.

# Create the service with the help of kubectl

Delete the existing Service: `kubectl delete svc/nginx`.

Create a new Service with kubectl. Check the possibilities: `kubectl create --help` and `kubectl create service --help`.

We can create a new Service like this: `kubectl create service nginx`. But we can not put a selector on it immediately.

Do it with the help of the previous command: `kubectl set selector svc/nginx cloud=native`

Try again with port forwarding and calling.

# Cleanup

Finally, delete the Pod and the Service: `kubectl delete pod/nginx svc/nginx`.
