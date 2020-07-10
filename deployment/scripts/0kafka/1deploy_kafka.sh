#!/usr/bin/env bash

if [[ -z $WORKSPACE || -z $SCHEMA_REGISTRY_PORT || -z $CONTROL_CENTER_PORT || -z $CONNECT_PORT || -z $CONNECT_PV_CLAIM_NAME || -z $CONNECT_PLUGIN_PATH || -z $KAFKA_MAINTENANCE_POD_NAME ]]; then
  echo 'One or more variables are undefined'
  exit 1
fi


terraform init ../../terraform
terraform workspace new ${WORKSPACE} ../../terraform || ../../terraform workspace select ${WORKSPACE} ../../terraform
terraform apply \
-var "schema_registry_port=${SCHEMA_REGISTRY_PORT}" \
-var "control_center_port=${CONTROL_CENTER_PORT}" \
-var "connect_port=${CONNECT_PORT}" \
-var "connect_pv_claim_name=${CONNECT_PV_CLAIM_NAME}" \
-var "connect_plugin_path=${CONNECT_PLUGIN_PATH}" \
-var "kafka_maintenance_pod_name=${KAFKA_MAINTENANCE_POD_NAME}" \
../../terraform
