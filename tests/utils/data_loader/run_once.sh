#!/usr/bin/env bash

if [ $# -ne 2 ]; then
    echo "Provide [data_folder] [schema_path] to proceed"
    exit 1
fi

DATA_FOLDER=$1
SCHEMA_PATH=$2

launch \
--data-dir ${DATA_FOLDER} \
--bootstrap-server `minikube ip`:32400 \
--schema-file-path ${SCHEMA_PATH} \
--schema-registry-url http://`minikube ip`:30801 \
--topic-name "${TOPIC_NAME}"
