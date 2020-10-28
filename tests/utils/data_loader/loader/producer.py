from typing import Dict

from avro.io import AvroTypeException
from confluent_kafka import avro
from confluent_kafka.avro import AvroProducer


def create_kafka_producer(config, value_schema):
    return AvroProducer(config, default_value_schema=value_schema)


def delivery_report(err, msg):
    """ Called once for each message produced to indicate delivery result.
        Triggered by poll() or flush(). """
    if err is not None:
        print('Message delivery failed: {}'.format(err))


class TestDataProducer:
    def __init__(self, kafka_host: str, schema_file_path: str, schema_registry_url: str,
                 topic_name: str):
        self._producer = create_kafka_producer(
            config={
                'acks': 1,
                'bootstrap.servers': kafka_host,
                'schema.registry.url': schema_registry_url,
                'on_delivery': delivery_report
            },
            value_schema=self._load_schema(schema_file_path)
        )
        self._topic_name = topic_name
        self._processed = 0
        self._schema_problems = 0
        self._other_problems = 0

    def _load_schema(self, schema_file_path: str):
        with open(schema_file_path, 'rb') as f:
            content = f.read().decode('utf-8-sig')
            return avro.loads(content)

    def push_data(self, content: Dict):
        try:
            self._producer.produce(topic=self._topic_name, value=content)
        except AvroTypeException:
            self._schema_problems += 1
        except Exception:
            self._other_problems += 1
        self._processed += 1

    def finish(self):
        self._producer.flush()
        print(f'Processed {self._processed} records: '
              f'({self._schema_problems} schema errors, '
              f'{self._other_problems} other errors).')
