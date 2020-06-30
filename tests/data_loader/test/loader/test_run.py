import os
import shutil
import uuid
from typing import Dict

import pytest
from confluent_kafka import Producer
from loader.run import load
from mock import patch, Mock, call


def _make_structure(base_path: str, dir_struct):
    for key, nested_struct in dir_struct.items():
        if isinstance(nested_struct, Dict):
            new_base = os.path.join(base_path, key)
            os.mkdir(new_base)
            _make_structure(new_base, nested_struct)
        else:
            file, lines = key, nested_struct
            with open(os.path.join(base_path, file), 'w') as f:
                f.write('\n'.join(lines))


@pytest.fixture
def test_directory():
    random_id = uuid.uuid4().hex
    os.mkdir(random_id)

    _make_structure(random_id, {
        'a': {
            'file_a1': ['msg_a1_1', 'msg_a1_2'],
            'file_a2': ['msg_a2_1']
        },
        'b': {
            'file_b1': ['msg_b1_1'],
            'b_a': {
                'file_b_a1': ['msg_b_a1_1'],
                'file_b_a2': ['msg_b_a2_1', 'msg_b_a2_2'],
                '.should_be_ignored': ['UNWANTED1', 'UNWANTED2'],
            },
            '.another_to_be_ignored': ['UNWANTED1', 'UNWANTED2'],
        },
        'c': {}
    })

    yield random_id

    shutil.rmtree(random_id)


def test_load(test_directory):
    producer_mock = Mock(spec_set=Producer)
    with patch('loader.run.create_kafka_producer', return_value=producer_mock) as producer_factory_mock:
        load(test_directory, 'broker', 'schemaregistry', 'topic')

        producer_factory_mock.assert_called_once_with({
            'bootstrap.servers': ['broker'],
            'acks': 1,
            'value.serializer': 'io.confluent.kafka.serializers.KafkaAvroSerializer',
            'schema.registry.url': 'schemaregistry'
        })
        producer_mock.send.assert_has_calls(
            [
                call('topic', bytes('msg_a1_1', 'utf-8')),
                call('topic', bytes('msg_a1_2', 'utf-8')),
                call('topic', bytes('msg_a2_1', 'utf-8')),
                call('topic', bytes('msg_b1_1', 'utf-8')),
                call('topic', bytes('msg_b_a1_1', 'utf-8')),
                call('topic', bytes('msg_b_a2_1', 'utf-8')),
                call('topic', bytes('msg_b_a2_2', 'utf-8'))
            ], any_order=True
        )
        assert producer_mock.send.call_count == 7, producer_mock.send.call_args_list
