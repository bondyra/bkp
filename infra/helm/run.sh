#!/usr/bin/env bash
if [ $# -ne 1 ]; then
    echo "Provide [namespace] to proceed"
    exit 1
fi

helm install --namespace $1 $1-elasticsearch stable/elasticsearch
