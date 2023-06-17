#!/bin/sh

kubectl create ns webinar
kubectl label ns/webinar monitoring=true
kubectl create secret generic postgres-password --from-literal password=password --from-literal postgres-password=postgres-password -n webinar
helm dependency update ../webinar
helm upgrade --install webinar ../webinar -n webinar
