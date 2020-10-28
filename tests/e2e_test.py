import time
from typing import Iterable, Dict

import requests
import uuid
import click
from loader import DataLoader
from producer import TestDataProducer
from source import DataSource


class SimpleSource(DataSource):
    def iter_rows(self) -> Iterable[Dict]:
        yield {'':''}  # TODO


@click.command()
@click.option('-b', '--bootstrap-server', required=True)
@click.option('-s', '--schema-file-path', required=True)
@click.option('-r', '--schema-registry-url', required=True)
@click.option('-t', '--topic-name', required=True)
@click.option('-u', '--search-service-url', required=True)
def run(bootstrap_server: str, schema_file_path: str, schema_registry_url: str, topic_name: str,
        search_service_url: str):
    search_string = uuid.uuid4().hex
    print(f'Starting test. Searched text will be: {search_string}')

    print('Pushing data')
    loader = DataLoader(
        source=None,
        producer=TestDataProducer(bootstrap_server, schema_file_path, schema_registry_url, topic_name)
    )
    loader.load()

    print('Sleeping for 10 secs')
    time.sleep(10)

    print('Searching result in search service')
    response = requests.get(f'{search_service_url}/search?pattern={search_string}')

    assert response.status_code == 200
    assert response.json() == [
        {
            '': ''
            # TODO
        }
    ]
