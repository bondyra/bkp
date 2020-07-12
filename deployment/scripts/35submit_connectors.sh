#!/usr/bin/env bash
set -e

if [[ -z $WORKSPACE || -z $CONNECT_PV_CLAIM_NAME ]]; then
  echo 'Define required env vars'
  exit 1
fi

MINIKUBE_PATH=$(get_minikube_connect_path.py -n $WORKSPACE -c $CONNECT_PV_CLAIM_NAME)

scp -i $(minikube ssh-key) ../../connectors/*.zip docker@$(minikube ip):$MINIKUBE_PATH

minikube ssh "for zipfile in ../../connectors/*.zip; do unzip $zipfile; done"
