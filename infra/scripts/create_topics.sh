#!/usr/bin/env bash

usage() {
    echo "Usage: $(basename "$0") [k8s namespace] [pod name] [bootstrap server] [topic name]"
}

if [[ "$#" -ne 4 ]]; then
    usage
    exit 1
fi

kubectl -n $1 exec $2 -- ./bin/kafka-topics.sh --bootstrap-server $3 --create --topic $4 --partitions 3 --replication-factor 3
