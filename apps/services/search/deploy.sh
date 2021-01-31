#!/usr/bin/env bash

if [[ -z $WORKSPACE ]]; then
  echo 'Define required env vars'
  exit 1
fi

./mvnw clean package k8s:build k8s:resource k8s:apply -Dnamespace=$WORKSPACE
