#!/bin/sh

kind create cluster --config ../cluster.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/686aeac5961f37eaf1ddfa2fa320df4ccf0cf005/deploy/static/provider/kind/deploy.yaml
