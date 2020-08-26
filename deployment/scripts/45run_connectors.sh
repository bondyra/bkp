#!/usr/bin/env bash
set -e

if [[ -z $CONNECT_PORT ]]; then
  echo 'Define required env vars'
  exit 1
fi

ES_SINK_CONNECTOR_NAME=$1

curl -X POST `minikube ip`:${CONNECT_PORT}/connectors --header "Content-Type:application/json" -d '{
  "name": "es-sink",
  "config": {
    "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
    "tasks.max": "1",
    "topics": "test",
    "key.ignore": "true",
    "connection.url": "http://elasticsearch-service:9200",
    "flush.timeout.ms": 20000,
    "connection.timeout.ms": 60000,
    "read.timeout.ms": 20000,
    "type.name": "kafka-connect",
    "value.converter":"io.confluent.connect.avro.AvroConverter",
    "value.converter.schema.registry.url": "http://schema-registry-service:8081"
  }
}'
