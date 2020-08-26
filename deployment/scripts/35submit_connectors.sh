#!/usr/bin/env bash
set -e

if [[ -z $WORKSPACE || -z $CONNECT_PV_CLAIM_NAME || -z $CONNECT_PORT ]]; then
  echo 'Define required env vars'
  exit 1
fi

if [ $# -ne 2 ]; then
    echo "Provide [connector_zips_folder] [connect_deployment_name] to proceed"
    exit 1
fi

CONNECTOR_ZIPS_FOLDER=$1
CONNECT_DEPLOYMENT_NAME=$2

MINIKUBE_PATH=$(get_minikube_connect_path.py -n $WORKSPACE -c $CONNECT_PV_CLAIM_NAME)

minikube ssh "rm -rf ${MINIKUBE_PATH}/*"

scp -i $(minikube ssh-key) ${CONNECTOR_ZIPS_FOLDER}/*.zip docker@$(minikube ip):${MINIKUBE_PATH}

minikube ssh "find ${MINIKUBE_PATH} -name \"*.zip\" -exec unzip -d ${MINIKUBE_PATH} {} \;"

echo "Restarting connect deployment"
kubectl -n $WORKSPACE rollout restart deployment $CONNECT_DEPLOYMENT_NAME
echo "Connect deployment was restarted. Sleeping for 30 secs"
sleep 30
echo "Please check if all your connector plugins are available now:"
curl -XGET `minikube ip`:$CONNECT_PORT/connector-plugins
