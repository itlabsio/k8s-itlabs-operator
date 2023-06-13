import json
from time import sleep

import pytest

from observability.metrics.decorator import monitoring, connector_time, mutation_hook_monitoring
from observability.metrics.metrics import app_http_request_operator_latency_seconds, \
    app_mutation_admission_hook_latency_seconds
from operators.dto import ConnectorStatus, MutationHookStatus

connector_time_type = 'connector_time_type'
monitoring_type = 'monitoring_type'
mutation_hook_monitoring_type = 'mutation_hook_monitoring_type'


@connector_time(connector_type=connector_time_type)
def simple_func_con(word: str, status: ConnectorStatus):
    print(f'Hello, {word}')
    sleep(0.1)
    return status


@monitoring(connector_type=monitoring_type)
def simple_func_mon(word: str, status: ConnectorStatus):
    print(f'Hello, {word}')
    sleep(0.1)
    return status


@mutation_hook_monitoring(connector_type=mutation_hook_monitoring_type)
def simple_func_hook(word: str, status: MutationHookStatus):
    print(f'Hello, {word}')
    sleep(0.1)
    return status


@pytest.mark.unit
class TestMonitoringDecorator:
    def test_decorator(self):
        status = ConnectorStatus()
        simple_func_mon('World', status)
        assert app_http_request_operator_latency_seconds._metrics
        metric = app_http_request_operator_latency_seconds._metrics.get(
            (monitoring_type, status.label_is_enabled, status.label_is_used, status.label_exception))
        assert metric._sum._value
        old_value = metric._sum._value
        simple_func_mon('World', status)
        assert app_http_request_operator_latency_seconds._metrics
        metric = app_http_request_operator_latency_seconds._metrics.get(
            (monitoring_type, status.label_is_enabled, status.label_is_used, status.label_exception))
        assert old_value != metric._sum._value

    def test_json_serializable(self):
        status = simple_func_mon('World', ConnectorStatus())
        assert json.dumps(status)
        assert isinstance(status, dict)
        assert len(status.keys()) == 1
        for key in status.keys():
            assert key == monitoring_type
            subdict = status[key]
            assert isinstance(subdict, dict)
            keys = ['enabled', 'used', 'exception']
            assert all(key in keys for key in subdict)


@pytest.mark.unit
class TestConnectorTimeDecorator:
    def test_connector_time(self):
        status = ConnectorStatus()
        simple_func_con('World', status)
        metric = app_http_request_operator_latency_seconds._metrics.get(
            (connector_time_type, status.label_is_enabled, status.label_is_used, status.label_exception))
        assert app_http_request_operator_latency_seconds._metrics
        old_value = metric._sum._value
        simple_func_con('World', status)
        metric = app_http_request_operator_latency_seconds._metrics.get(
            (connector_time_type, status.label_is_enabled, status.label_is_used, status.label_exception))
        assert metric._sum._value
        assert old_value != metric._sum._value

    def test_json_serializable(self):
        status = simple_func_con('World', ConnectorStatus())
        assert json.dumps(status)
        assert isinstance(status, dict)
        assert len(status.keys()) == 1
        for key in status.keys():
            assert key == connector_time_type
            subdict = status[key]
            assert isinstance(subdict, dict)
            keys = ['enabled', 'used', 'exception']
            assert all(key in keys for key in subdict)


@pytest.mark.unit
class TestMutationHookMonitoringTypeDecorator:
    def test_decorator(self):
        status = MutationHookStatus()
        simple_func_hook('World', status)
        assert app_mutation_admission_hook_latency_seconds._metrics
        metric = app_mutation_admission_hook_latency_seconds._metrics.get(
            (mutation_hook_monitoring_type, status.label_is_used, status.label_is_success)
        )
        assert metric._sum._value
        old_value = metric._sum._value
        simple_func_hook('World', status)
        assert app_mutation_admission_hook_latency_seconds._metrics
        metric = app_mutation_admission_hook_latency_seconds._metrics.get(
            (mutation_hook_monitoring_type, status.label_is_used,
             status.label_is_success)
        )
        assert old_value != metric._sum._value

    def test_json_serializable(self):
        status = simple_func_hook('World', MutationHookStatus())
        assert json.dumps(status)
        assert isinstance(status, dict)
        assert len(status.keys()) == 1
        for key in status.keys():
            assert key == mutation_hook_monitoring_type
            subdict = status[key]
            assert isinstance(subdict, dict)
            keys = ['used', 'success']
            assert all(key in keys for key in subdict)
