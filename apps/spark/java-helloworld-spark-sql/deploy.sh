#!/usr/bin/env bash
set -ex

mvn package

eval $(minikube -p minikube docker-env)
docker build -t java-helloworld-spark-sql:0.1 .

kubectl apply -f spark-app.yml
