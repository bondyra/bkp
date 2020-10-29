import json
import time
from datetime import datetime
from typing import Iterable, Dict

import click
import requests
import uuid
from loader.loader import DataLoader
from loader.producer import TestDataProducer
from loader.source import DataSource


class SingleOfferInMemorySource(DataSource):
    def __init__(self, offer: Dict):
        self._offer = offer

    def iter_rows(self) -> Iterable[Dict]:
        yield self._offer


def _load_offer(file_path: str, expected_title: str, expected_link: str, expected_gather_date: datetime,
                searched_string: str) -> Dict:
    with open(file_path, 'r') as file:
        for line in file.readlines():
            offer = json.loads(line.strip())
            offer['link'] = expected_link
            offer['gather_date'] = str(expected_gather_date.isoformat())
            offer['content']['title'] = expected_title
            offer['content']['text'] = f'text{searched_string}text'
            return offer


@click.command()
@click.option('-o', '--offer-json-file-path', required=True)
@click.option('-b', '--bootstrap-server', required=True)
@click.option('-s', '--schema-file-path', required=True)
@click.option('-r', '--schema-registry-url', required=True)
@click.option('-t', '--topic-name', required=True)
@click.option('-u', '--search-service-url', required=True)
def run(offer_json_file_path: str, search_service_url: str,
        bootstrap_server: str, schema_file_path: str, schema_registry_url: str, topic_name: str):
    searched_string = uuid.uuid4().hex
    expected_title = f'Test offer with text {searched_string}'
    expected_link = "http://tibia.pl:1488"
    expected_gather_date = datetime(2005, 4, 2, 21, 37)
    offer = _load_offer(offer_json_file_path, expected_title, expected_link, expected_gather_date, searched_string)

    print(f'Pushing test offer. Searched text will be: {searched_string}')
    loader = DataLoader(
        source=SingleOfferInMemorySource(offer),
        producer=TestDataProducer(bootstrap_server, schema_file_path, schema_registry_url, topic_name)
    )
    loader.load()

    print('Sync await for 10 seconds')
    time.sleep(10)

    print('Verifying results')
    response = requests.get(f'{search_service_url}/search?pattern={searched_string}')

    assert response.status_code == 200
    matching_items = response.json()
    assert len(matching_items) == 1
    indexed_offer = matching_items[0]
    assert indexed_offer['link'] == ''
    assert indexed_offer['title'] == ''
    assert indexed_offer['gatherDate'] == ''
    print('All OK')


if __name__ == '__main__':
    run()
