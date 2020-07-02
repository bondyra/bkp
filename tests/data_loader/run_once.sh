#!/usr/bin/env bash

launch \
--data-dir ../bkp-test-data/data2 \
--bootstrap-server `minikube ip`:32400 \
--schema-file-path ../bkp-test-data/schema2.json \
--schema-registry-url http://`minikube ip`:30801 \
--topic-name test5
