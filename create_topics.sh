#!/usr/bin/env bash

source config

kubectl \
-n ${WORKSPACE} \
exec ${KAFKA_MAINTENANCE_POD_NAME} -- \
    ./bin/kafka-topics.sh \
        --bootstrap-server broker:9092 \
        --create \
        --topic ${TOPIC_NAME} \
        --partitions 3 \
        --replication-factor 3
