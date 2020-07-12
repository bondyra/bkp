#!/usr/bin/env bash
set -e

if [[ -z $WORKSPACE || -z $KAFKA_MAINTENANCE_POD_NAME || -z $TOPIC_NAME ]]; then
  echo 'Define required env vars'
  exit 1
fi

kubectl \
-n ${WORKSPACE} \
exec ${KAFKA_MAINTENANCE_POD_NAME} -- \
    ./bin/kafka-topics.sh \
        --bootstrap-server broker:9092 \
        --create \
        --topic ${TOPIC_NAME} \
        --partitions 3 \
        --replication-factor 3
