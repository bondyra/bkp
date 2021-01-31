#!/usr/bin/env bash
set -ex

eval $(minikube -p minikube docker-env)
docker build -t python-helloworld-spark-sql:0.1 .

kubectl apply -f spark-app.yml
