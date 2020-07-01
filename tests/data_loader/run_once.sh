#!/usr/bin/env bash

launch \
--data-dir ../bkp-test-data/data \
--bootstrap-server `minikube ip`:32400 \
--schema-file-path ../bkp-test-data/schema.json \
--schema-registry-url http://`minikube ip`:30801 \
--topic-name test
