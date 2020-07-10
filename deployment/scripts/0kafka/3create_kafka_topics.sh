#!/usr/bin/env bash

if [[ -z $WORKSPACE || -z $KAFKA_MAINTENANCE_POD_NAME || -z $TOPIC_NAME ]]; then
  echo 'One or more variables are undefined'
  exit 1
fi

python3 ./wait_for_brokers.py -n ${WORKSPACE} -p kafka-0 kafka-1 kafka-2

if [ $? -ne 0 ]; then exit 1; fi  # todo: set -e

kubectl \
-n ${WORKSPACE} \
exec ${KAFKA_MAINTENANCE_POD_NAME} -- \
    ./bin/kafka-topics.sh \
        --bootstrap-server broker:9092 \
        --create \
        --topic ${TOPIC_NAME} \
        --partitions 3 \
        --replication-factor 3
