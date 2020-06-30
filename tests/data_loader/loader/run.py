import logging
import os
from typing import Iterable

import click
from confluent_kafka import Producer

logger = logging.getLogger(__name__)


def create_kafka_producer(config):
    return Producer(config)


def _iter_files_recursive(dir: str) -> Iterable[str]:
    for dir, subdirs, files in os.walk(dir):
        for file in files:
            if not file.startswith('.'):
                yield os.path.join(dir, file)


def _read_file(file_path: str) -> Iterable[str]:
    with open(file_path, 'r') as file:
        for line in file.readlines():
            yield line.strip()


class TestDataProducer:
    def __init__(self, kafka_host: str, schema_registry_url: str, topic_name: str):
        self._producer = create_kafka_producer(
            {
                'bootstrap.servers': [kafka_host],
                'acks': 1,
                'value.serializer': 'io.confluent.kafka.serializers.KafkaAvroSerializer',
                'schema.registry.url': schema_registry_url
            }
        )
        self._topic_name = topic_name

    def push_data(self, content: str):
        # TODO schema!
        self._producer.send(self._topic_name, bytes(content, 'utf-8'))


def load(data_dir: str, bootstrap_server: str, schema_registry_url: str, topic_name: str):
    producer = TestDataProducer(bootstrap_server, schema_registry_url, topic_name)
    for file_path in _iter_files_recursive(data_dir):
        for line in _read_file(file_path):
            producer.push_data(content=line)


@click.command()
@click.option('-d', '--data-dir', required=True)
@click.option('-b', '--bootstrap-server', required=True)
@click.option('-s', '--schema-registry', required=True)
@click.option('-t', '--topic-name', required=True)
def run(data_dir: str, bootstrap_server: str, schema_registry_url: str, topic_name: str):
    logger.info(f'Run started')
    load(data_dir, bootstrap_server, schema_registry_url, topic_name)
    logger.info(f'Run finished, exiting')


if __name__ == '__main__':
    run()
