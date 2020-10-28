import logging

import click
from loader.loader import DataLoader
from loader.producer import TestDataProducer
from loader.source import DirectorySource

logger = logging.getLogger(__name__)


def do_run(data_dir: str, bootstrap_server: str, schema_file_path: str, schema_registry_url: str,
           topic_name: str):
    loader = DataLoader(
        source=DirectorySource(data_dir),
        producer=TestDataProducer(bootstrap_server, schema_file_path, schema_registry_url, topic_name)
    )
    loader.load()


@click.command()
@click.option('-d', '--data-dir', required=False)
@click.option('-b', '--bootstrap-server', required=True)
@click.option('-s', '--schema-file-path', required=True)
@click.option('-r', '--schema-registry-url', required=True)
@click.option('-t', '--topic-name', required=True)
def run(data_dir: str, bootstrap_server: str, schema_file_path: str, schema_registry_url: str,
        topic_name: str):
    do_run(data_dir, bootstrap_server, schema_file_path, schema_registry_url, topic_name)


if __name__ == '__main__':
    run()
