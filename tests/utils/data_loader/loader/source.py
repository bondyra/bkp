import json
import logging
import os
from typing import Iterable, Dict

logger = logging.getLogger(__name__)


class DataSource:
    def iter_rows(self) -> Iterable[Dict]:
        raise NotImplemented()


class DirectorySource(DataSource):
    def __init__(self, data_dir: str):
        self._data_dir = data_dir

    def iter_rows(self) -> Iterable[Dict]:
        for file_path in self._iter_files_recursive():
            yield from self._read_file(file_path)

    def _iter_files_recursive(self) -> Iterable[str]:
        for dir, subdirs, files in os.walk(self._data_dir):
            for file in files:
                if not file.startswith('.'):
                    yield os.path.join(dir, file)

    def _read_file(self, file_path: str) -> Iterable[Dict]:
        with open(file_path, 'r') as file:
            for line in file.readlines():
                yield json.loads(line.strip())
