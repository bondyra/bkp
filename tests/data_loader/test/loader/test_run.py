import os
import shutil
import uuid
from typing import Dict

import pytest
from confluent_kafka import Producer
from loader.run import load, delivery_report
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
            'a1': ['{"msg": "a_a1_1"}', '{"msg": "a_a1_2"}'],
            'a2': ['{"msg": "a_a2_1"}']
        },
        'b': {
            'b1': ['{"msg": "b_b1_1"}'],
            'b2': {
                'a1': ['{"msg": "b_b2_a1_1"}'],
                'a2': ['{"msg": "b_b2_a2_1"}', '{"msg": "b_b2_a2_2"}'],
                '.should_be_ignored': ['UNWANTED1', 'UNWANTED2'],
            },
            '.another_to_be_ignored': ['UNWANTED1', 'UNWANTED2'],
        },
        'c': {}
    })

    yield random_id

    shutil.rmtree(random_id)


@pytest.fixture
def schema_file_path():
    random_id = uuid.uuid4().hex
    with open(random_id, 'w') as f:
        f.write('SCHEMA')

    yield random_id

    os.remove(random_id)


def test_load(test_directory, schema_file_path):
    producer_mock = Mock(spec_set=Producer)
    with patch('loader.run.create_kafka_producer', return_value=producer_mock) as producer_factory_mock, \
            patch('confluent_kafka.avro.loads', return_value='MOCK_AVRO_SCHEMA') as mock_avro_loads:
        load(test_directory, 'broker', schema_file_path, 'schemaregistry', 'topic')

        mock_avro_loads.assert_called_once_with('SCHEMA')
        producer_factory_mock.assert_called_once_with(
            config={
                'acks': 1,
                'bootstrap.servers': 'broker',
                'schema.registry.url': 'schemaregistry',
                'on_delivery': delivery_report
            },
            value_schema='MOCK_AVRO_SCHEMA'
        )
        producer_mock.produce.assert_has_calls(
            [
                call(topic='topic', value={'msg': 'a_a1_1'}),
                call(topic='topic', value={'msg': 'a_a1_2'}),
                call(topic='topic', value={'msg': 'a_a2_1'}),
                call(topic='topic', value={'msg': 'b_b1_1'}),
                call(topic='topic', value={'msg': 'b_b2_a1_1'}),
                call(topic='topic', value={'msg': 'b_b2_a2_1'}),
                call(topic='topic', value={'msg': 'b_b2_a2_2'})
            ], any_order=True
        )
        assert producer_mock.produce.call_count == 7, producer_mock.send.call_args_list
        producer_mock.flush.assert_called_once()
