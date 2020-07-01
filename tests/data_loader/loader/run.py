import json
import logging
import os
from typing import Iterable, Dict

import click
from confluent_kafka import avro
from confluent_kafka.avro import AvroProducer

logger = logging.getLogger(__name__)


def create_kafka_producer(config, value_schema):
    return AvroProducer(config, default_value_schema=value_schema)


def _iter_files_recursive(dir: str) -> Iterable[str]:
    for dir, subdirs, files in os.walk(dir):
        for file in files:
            if not file.startswith('.'):
                yield os.path.join(dir, file)


def _read_file(file_path: str) -> Iterable[str]:
    with open(file_path, 'r') as file:
        for line in file.readlines():
            yield json.loads(line.strip())


class TestDataProducer:
    def __init__(self, kafka_host: str, schema_file_path: str, schema_registry_url: str,
                 topic_name: str):
        self._producer = create_kafka_producer(
            config={
                'acks': 0,
                'bootstrap.servers': kafka_host,
                'schema.registry.url': schema_registry_url
            },
            value_schema=self._load_schema(schema_file_path)
        )
        self._topic_name = topic_name

    def _load_schema(self, schema_file_path: str):
        with open(schema_file_path, 'rb') as f:
            content = f.read().decode('utf-8-sig')  # NOTE: remember - no sig for json2!
            return avro.loads(content)

    def push_data(self, content: Dict):
        self._producer.produce(topic=self._topic_name, value=content)


def load(data_dir: str, bootstrap_server: str, schema_file_path: str, schema_registry_url: str,
         topic_name: str):
    producer = TestDataProducer(bootstrap_server, schema_file_path, schema_registry_url, topic_name)
    for file_path in _iter_files_recursive(data_dir):
        for line in _read_file(file_path):
            producer.push_data(content=line)


@click.command()
@click.option('-d', '--data-dir', required=True)
@click.option('-b', '--bootstrap-server', required=True)
@click.option('-s', '--schema-file-path', required=True)
@click.option('-r', '--schema-registry-url', required=True)
@click.option('-t', '--topic-name', required=True)
def run(data_dir: str, bootstrap_server: str, schema_file_path: str, schema_registry_url: str,
        topic_name: str):
    logger.info(f'Run started')
    load(data_dir, bootstrap_server, schema_file_path, schema_registry_url, topic_name)
    logger.info(f'Run finished, exiting')


if __name__ == '__main__':
    run()
