#!/usr/bin/env bash

if [[ -z $WORKSPACE ]]; then
  echo 'Workspace is undefined'
  exit 1
fi


test echo "Set workspace!" && exit 1; fi

helm install --namespace $WORKSPACE $WORKSPACE-elasticsearch stable/elasticsearch
