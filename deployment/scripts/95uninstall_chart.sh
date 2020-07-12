#!/usr/bin/env bash

if [[ -z $WORKSPACE ]]; then
  echo 'Define required WORKSPACE env var'
  exit 1
fi

if [ $# -ne 1 ]; then
    echo "Provide [chart_name] to proceed. WITHOUT WORKSPACE!"
    exit 1
fi

helm uninstall --namespace $WORKSPACE $WORKSPACE-$1
