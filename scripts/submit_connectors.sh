#!/usr/bin/env bash
if [ $# -ne 3 ]; then
    echo "Required [namespace] [connect_pv_claim_name] [connector_zip_folder]"
    exit 1
fi

NAMESPACE=$1
CONNECT_PV_CLAIM_NAME=$2
MINIKUBE_PATH=$(python3 ./get_minikube_connect_path.py.py -n $NAMESPACE -c $CONNECT_PV_CLAIM_NAME)

CONNECTORS_FOLDER=$3
scp -i $(minikube ssh-key) ${CONNECTORS_FOLDER}/* docker@$(minikube ip):$MINIKUBE_PATH

minikube ssh "for zipfile in ${MINIKUBE_PATH}/*.zip; do unzip $zipfile; done"
