#!/usr/bin/env bash

source config

./terraform init infra/terraform
./terraform workspace new ${WORKSPACE} infra/terraform || ./terraform workspace select ${WORKSPACE} infra/terraform
./terraform apply \
-var "schema_registry_port=${SCHEMA_REGISTRY_PORT}" \
-var "control_center_port=${CONTROL_CENTER_PORT}" \
-var "connect_port=${CONNECT_PORT}" \
-var "connect_plugin_path=${CONNECT_PLUGIN_PATH}" \
-var "kafka_maintenance_pod_name=${KAFKA_MAINTENANCE_POD_NAME}" \
infra/terraform
