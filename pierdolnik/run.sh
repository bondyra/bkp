#!/usr/bin/env bash

curl -v -X POST `minikube ip`:30808/connectors --header 'Content-Type:application/json' -d"@esconnector.json"
