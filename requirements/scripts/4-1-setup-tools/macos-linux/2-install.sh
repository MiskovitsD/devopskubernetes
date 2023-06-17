#!/bin/sh

kubectl create ns tools
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack --version 41.7.0 -f ../prometheus.yaml -n tools
helm upgrade --install loki grafana/loki -f ../loki.yaml --version 4.6.1 -n tools
helm upgrade --install promtail grafana/promtail --set "config.clients[0].url=http://loki:3100/loki/api/v1/push" --version 6.8.3 -n tools
helm upgrade --install tempo grafana/tempo -f ../tempo.yaml --version 1.0.0 -n tools
kubectl apply -f ../grafana.yaml -n tools
