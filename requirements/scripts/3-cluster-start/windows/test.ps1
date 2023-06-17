kubectl run hello --expose --image nginxdemos/hello:plain-text --port 80
kubectl apply -f ../ingress.yaml

sleep 5

curl http://application.cubix.localhost:8080/test
kubectl delete pod/hello svc/hello ingress/hello
