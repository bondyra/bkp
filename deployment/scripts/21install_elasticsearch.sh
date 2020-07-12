#!/usr/bin/env bash
set -e

if [[ -z $WORKSPACE ]]; then
  echo 'Define required WORKSPACE env var'
  exit 1
fi

helm install --namespace $WORKSPACE $WORKSPACE-elasticsearch stable/elasticsearch
