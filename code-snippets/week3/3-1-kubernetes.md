# YAML

## Tool for formatting and validating YAML

https://www.yamllint.com/


# Pod and Service exercise

## Example Pod

https://kubernetes.io/docs/concepts/workloads/pods/#using-pods

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

## Example Service

https://kubernetes.io/docs/concepts/services-networking/service/#defining-a-service

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

## Local port-forwarding URL

http://localhost:9090


# Deployment and Ingress exercise

## Example Deployment

https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#creating-a-deployment

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

## Local port-forwarding URL

http://localhost:9090

## Example Ingress

https://kubernetes.io/docs/concepts/services-networking/ingress/#the-ingress-resource

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

## Local URL for Ingress

http://localhost:8080


# Other useful kubectl commands exercise

## Running a command in an existing Pod

There is a difference here between PowerShell and Shell - how to escape a special character that would be otherwise processed.

PowerShell:

```powershell
kubectl exec deploy/nginx -- echo `$KUBERNETES_PORT
kubectl exec deploy/nginx -- sh -c "echo `$KUBERNETES_PORT"
```

Bash/Shell:

```shell
kubectl exec deploy/nginx -- echo \$KUBERNETES_PORT
kubectl exec deploy/nginx -- sh -c "echo \$KUBERNETES_PORT"
```

