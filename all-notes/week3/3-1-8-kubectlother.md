# Kubectl get

We used `kubectl get pods` `kubectl get service`. We can do shortenings: `kubectl get svc`. Also we can query the most basic resource types: `kubectl get all`.

# Kubectl get with selector

We can use selectors for querying resources: `kubectl get pods -l app=nginx`.

# Enter a running Pod

For debugging we might want to enter a Pod of a Deployment. We can enter it as a Terminal: `kubectl exec deploy/nginx -it -- sh`

Or we can simply issue a command: `kubectl exec deploy/nginx -- ls`

Note that in the latter case, a Shell must be open first for using environment variables:

```shell
kubectl exec deploy/nginx -- echo `$KUBERNETES_PORT
kubectl exec deploy/nginx -- sh -c "echo `$KUBERNETES_PORT"
```

# Start a debug pod

Ephemeral containers are containers that can be temporarily running in an already existing Pod. 
Sometimes these might be necessary, for example because the container we want to debug does not have some utilities (i.e. curl).

Create it: `kubectl debug deploy/nginx -it --image=busybox` Do: `curl localhost:80`.

We can do a duplicate of a Pod, so we can for example find out why it crashes on startup:
`kubectl debug deploy/nginx -it --copy-to=nginx-debug --container=nginx -- sh` Do: `curl localhost:80`.
Note that a deletion must be made afterwards.

# Copy files

Copying files is possible between our local machine and a target Pod.

Copy from there: `kubectl cp pod/<>:/usr/share/nginx/html/hello.txt hello.txt`

Check it, change it, and copy it back: `kubectl cp hello.txt pod/<>:/usr/share/nginx/html/hello.txt`

Check the result: http://localhost:8080/hello.txt

# Used resources

Our cluster is too primitive, if it had appropriate resource monitoring features, the `kubectl top` would help us tell the most resource intensive containers.

# Delete multiple resources by labels

Delete everything with the help of the labels: `kubectl delete all -l app=nginx`. Check: `kubectl get all`.

