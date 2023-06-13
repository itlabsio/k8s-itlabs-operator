import pytest
import requests
from prometheus_client.parser import text_string_to_metric_families


@pytest.mark.e2e
def test_metrics_route():
    response = requests.get(url='http://k8s-itlabs-operator.k8s-itlabs-operator:8080')
    assert response.status_code == 200


@pytest.mark.e2e
def test_app_http_request_operator_latency_seconds():
    metric_name = 'app_http_request_operator_latency_seconds'
    is_metric_found = False
    response = requests.get(url='http://k8s-itlabs-operator.k8s-itlabs-operator:8080')
    resp_text = response.text
    parsed_metrics = text_string_to_metric_families(resp_text)
    for family in parsed_metrics:
        if family.name == metric_name:
            is_metric_found = True
            break
    assert is_metric_found


@pytest.mark.e2e
def test_app_http_request_operator_client_latency_seconds():
    metric_name = 'app_http_request_operator_client_latency_seconds'
    is_metric_found = False
    response = requests.get(url='http://k8s-itlabs-operator.k8s-itlabs-operator:8080')
    resp_text = response.text
    parsed_metrics = text_string_to_metric_families(resp_text)
    for family in parsed_metrics:
        if family.name == metric_name:
            is_metric_found = True
            break
    assert is_metric_found


@pytest.mark.e2e
def test_app_mutation_admission_hook_latency_seconds():
    metric_name = 'app_mutation_admission_hook_latency_seconds'
    is_metric_found = False
    response = requests.get(
        url='http://k8s-itlabs-operator.k8s-itlabs-operator:8080')
    resp_text = response.text
    parsed_metrics = text_string_to_metric_families(resp_text)
    for family in parsed_metrics:
        if family.name == metric_name:
            is_metric_found = True
            break
    assert is_metric_found
