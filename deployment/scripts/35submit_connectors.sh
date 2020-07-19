#!/usr/bin/env bash
set -e

if [[ -z $WORKSPACE || -z $CONNECT_PV_CLAIM_NAME ]]; then
  echo 'Define required env vars'
  exit 1
fi

if [ $# -ne 1 ]; then
    echo "Provide [connector_zips_folder] to proceed"
    exit 1
fi

CONNECTOR_ZIPS_FOLDER=$1

MINIKUBE_PATH=$(get_minikube_connect_path.py -n $WORKSPACE -c $CONNECT_PV_CLAIM_NAME)

minikube ssh "rm -rf ${MINIKUBE_PATH}/*"

scp -i $(minikube ssh-key) ${CONNECTOR_ZIPS_FOLDER}/*.zip docker@$(minikube ip):${MINIKUBE_PATH}

for zipfile in $(minikube ssh "ls ${MINIKUBE_PATH}/*.zip");
do
    echo $zipfile
    echo $MINIKUBE_PATH
    echo $zipfile $MINIKUBE_PATH
#    minikube ssh "unzip $zipfile -d ${MINIKUBE_PATH}"
done
