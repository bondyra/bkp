#!/usr/bin/env bash

if [ -z ${TOPIC_NAME} ]; then
echo "Specify TOPIC_NAME"
exit 1
fi

launch \
--data-dir ../bkp-test-data/data \
--bootstrap-server `minikube ip`:32400 \
--schema-file-path ../bkp-test-data/schema.avsc \
--schema-registry-url http://`minikube ip`:30801 \
--topic-name "${TOPIC_NAME}"
