import pytest
import requests


@pytest.mark.e2e
def test_healthz():
    response = requests.get(url="http://k8s-itlabs-operator.k8s-itlabs-operator:8090/healthz")
    assert response
    assert response.status_code == 200
    data = response.json()
    assert "now" in data
    assert "random" in data
