#!/usr/bin/env bash
set -e

if [[ -z $WORKSPACE || -z $SCHEMA_REGISTRY_PORT || -z $CONTROL_CENTER_PORT || -z $CONNECT_PORT || -z $CONNECT_PV_CLAIM_NAME || -z $CONNECT_PLUGIN_PATH || -z $KAFKA_MAINTENANCE_POD_NAME || -z $ELASTICSEARCH_PORT ]]; then
  echo 'Define required env vars'
  exit 1
fi

if [ $# -ne 1 ]; then
    echo "Provide [terraform_folder] to proceed"
    exit 1
fi

TERRAFORM_FOLDER=`pwd`/$1

terraform init ${TERRAFORM_FOLDER}
terraform workspace new ${WORKSPACE} ${TERRAFORM_FOLDER} || terraform workspace select ${WORKSPACE} ${TERRAFORM_FOLDER}
terraform apply -auto-approve \
-var "schema_registry_port=${SCHEMA_REGISTRY_PORT}" \
-var "control_center_port=${CONTROL_CENTER_PORT}" \
-var "connect_port=${CONNECT_PORT}" \
-var "connect_pv_claim_name=${CONNECT_PV_CLAIM_NAME}" \
-var "connect_plugin_path=${CONNECT_PLUGIN_PATH}" \
-var "kafka_maintenance_pod_name=${KAFKA_MAINTENANCE_POD_NAME}" \
-var "elasticsearch_port=${ELASTICSEARCH_PORT}" \
${TERRAFORM_FOLDER}
