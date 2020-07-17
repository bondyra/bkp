#!/usr/bin/env bash

if [ $# -ne 1 ]; then
    echo "Provide [images_folder] to proceed"
    exit 1
fi

docker build -t bkp-es $1/elasticsearch
