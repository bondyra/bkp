#!/usr/bin/env bash
set -e

if [[ -z $WORKSPACE ]]; then
  echo 'Define required WORKSPACE env var'
  exit 1
fi

wait_for_brokers.py -n ${WORKSPACE} -p kafka-0 kafka-1 kafka-2
