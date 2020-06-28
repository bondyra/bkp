#!/usr/bin/env bash

kubectl get pv | tail -n +2 | awk '{if ($5=="Released") { print $1 }}' | xargs -- kubectl delete pv
