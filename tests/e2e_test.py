import json
import logging
import time
from datetime import datetime
from loader.loader import DataLoader
from loader.producer import TestDataProducer
from loader.source import DataSource
from typing import Iterable, Dict

import click
import requests
import uuid

logging.basicConfig()


class SingleOfferInMemorySource(DataSource):
    def __init__(self, offer: Dict):
        self._offer = offer

    def iter_rows(self) -> Iterable[Dict]:
        yield self._offer


def _load_offer(file_path: str, expected_title: str, expected_link: str, expected_gather_date: str,
                searched_string: str) -> Dict:
    with open(file_path, 'r') as file:
        for line in file.readlines():
            offer = json.loads(line.strip())
            offer['link'] = expected_link
            offer['gather_date'] = expected_gather_date
            offer['content']['title'] = expected_title
            offer['content']['text'] = f'some text {searched_string} some other text'
            return offer


@click.command()
@click.option('-o', '--offer-json-file-path', required=True)
@click.option('-b', '--bootstrap-server', required=True)
@click.option('-s', '--schema-file-path', required=True)
@click.option('-r', '--schema-registry-url', required=True)
@click.option('-t', '--topic-name', required=True)
@click.option('-u', '--search-service-url', required=True)
@click.option('--debug', is_flag=True, default=False)
def run(offer_json_file_path: str, search_service_url: str,
        bootstrap_server: str, schema_file_path: str, schema_registry_url: str, topic_name: str, debug: bool = False):
    logger = logging.getLogger('E2E')
    if debug:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)
    searched_string = uuid.uuid4().hex
    expected_title = f'E2E test offer {searched_string} {datetime.now().isoformat()}'
    expected_link = "http://tibia.pl:1488"
    expected_gather_date = str(datetime(2005, 4, 2, 21, 37).isoformat())
    offer = _load_offer(offer_json_file_path, expected_title, expected_link, expected_gather_date, searched_string)

    logger.debug(f'Pushing test offer. Searched text will be: {searched_string}')
    loader = DataLoader(
        source=SingleOfferInMemorySource(offer),
        producer=TestDataProducer(bootstrap_server, schema_file_path, schema_registry_url, topic_name)
    )
    loader.load()

    logger.debug('Sync await for 10 seconds')
    time.sleep(10)

    logger.debug('Verifying results')
    response = requests.get(f'{search_service_url}/search?pattern={searched_string}')

    logger.debug(f'Response status: {response.status_code}')
    assert response.status_code == 200
    matching_items = response.json()
    logger.debug(f'Response JSON body: {matching_items}')
    assert len(matching_items) == 1
    indexed_offer = matching_items[0]
    assert indexed_offer['link'] == expected_link, f'Link: {indexed_offer["link"]} is different than expected: {expected_link}'
    assert indexed_offer['title'] == expected_title, f'Title: {indexed_offer["title"]} is different than expected: {expected_title}'
    assert indexed_offer['gatherDate'] == expected_gather_date, f'Date: {indexed_offer["gatherDate"]} is different than expected: {expected_gather_date}'
    logger.info('Completed successfully')


if __name__ == '__main__':
    run()
