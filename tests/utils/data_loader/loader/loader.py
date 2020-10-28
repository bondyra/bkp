import logging

from loader.producer import TestDataProducer
from loader.source import DataSource


class DataLoader:
    def __init__(self, source: DataSource, producer: TestDataProducer):
        self._source = source
        self._producer = producer
        self._logger = logging.getLogger(self.__class__.__name__)

    def load(self):
        self._logger.info(f'Run started')
        for row in self._source.iter_rows():
            self._producer.push_data(content=row)
        self._producer.finish()
        self._logger.info(f'Run finished, exiting')
