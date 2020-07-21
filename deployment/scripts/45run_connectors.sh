#!/usr/bin/env bash

{
  "name": "elasticsearch-test-sink",
  "config": {
    "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
    "tasks.max": "1",
    "topics": "test",
    "key.ignore": "true",
    "schema.registry.url": "http://schema-registry-service:8081",
    "connection.url": "http://elasticsearch-service:9200",
    "type.name": "kafka-connect",
    "name": "elasticsearch-sink"
  },
  "tasks": []
}

