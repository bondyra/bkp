#!/usr/bin/env bash

if [[ -z $ELASTICSEARCH_PORT ]]; then
  echo 'Define required env vars'
  exit 1
fi

curl `minikube ip`:$ELASTICSEARCH_PORT
