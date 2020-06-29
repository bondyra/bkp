import logging
import os
from typing import Iterable

import click
from kafka import KafkaProducer

logger = logging.getLogger(__name__)


def _iter_files_recursive(dir: str) -> Iterable[str]:
    for dir, subdirs, files in os.walk(dir):
        yield [os.path.join(dir, file) for file in files if not file.startswith('.')]
        for subdir in subdirs:
            yield from _iter_files_recursive(os.path.join(dir, subdir))


def _read_file(file_path: str) -> Iterable[str]:
    with open(file_path, 'r') as file:
        yield from file.readlines()


class TestDataProducer:
    def __init__(self, host: str, topic_name: str):
        self._producer = KafkaProducer(bootstrap_servers=host, acks=0)
        self._topic_name = topic_name

    def push_data(self, content: str):
        # TODO schema!
        self._producer.send(self._topic_name, bytes(content))


@click.command()
@click.option('-d', '--data-dir', required=True)
@click.option('-s', '--bootstrap_server', required=True)
@click.option('-t', '--topic_name', required=True)
def run(data_dir: str, bootstrap_server: str, topic_name: str):
    logger.info(f'Run started')
    producer = TestDataProducer(bootstrap_server, topic_name)
    for file_path in _iter_files_recursive(data_dir):
        for line in _read_file(file_path):
            producer.push_data(content=line)
    logger.info(f'Run finished, exiting')


if __name__ == '__main__':
    run()
