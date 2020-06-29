import os

import pytest

from loader.run import load_config, validate_config, get_input, get_output


def test_correct_config():
    config = load_config(os.path.join(os.path.dirname(__file__), 'config.json'))
    assert config == {
        'input': {
            'type': 'something',
            'args': {
                'param1': 'value1'
            }
        },
        'output': {
            'type': 'something',
            'args': {
                'param2': 'value2'
            }
        }
    }

    validate_config(config)


@pytest.mark.parametrize('invalid_config',
                         [
                             {},
                             {'input': 'str'},
                             {'input': {'type': 'x'}, 'output': 'str'},
                             {'input': {'type': 'x'}, 'output': {'type': 'x'}},
                             {'input': {'type': 'x', 'args': {}}, 'output': {'type': 'x', 'args': 'str'}},
                         ])
def test_incorrect_configs(invalid_config):
    with pytest.raises(Exception):
        validate_config(invalid_config)


def test_get_otodom_input():
    get_input(
        {
            'type': 'otodom',
            'args': {
                'base_urls': ['bu1', 'bu2'],
                'base_url_wait_seconds': 1,
                'repetitions': 2,
                'repetition_wait_seconds': 3600,
                'offer_url_part': 'oup'
            }
        }
    )
    with pytest.raises(Exception):
        get_input(
            {
                'type': 'otodom',
                'args': {
                    'x': 'x'
                }
            }
        )


def test_get_file_input():
    get_input({'type': 'file', 'args': {'dir_path': 'x'}})
    with pytest.raises(Exception):
        get_input({'type': 'file', 'args': {'x': 'x'}})


def test_get_file_output():
    output_config = {'type': 'file', 'args': {'dir_path': 'x'}}
    get_output(output_config)
    with pytest.raises(Exception):
        get_output({'type': 'file', 'args': {'x': 'x'}})
