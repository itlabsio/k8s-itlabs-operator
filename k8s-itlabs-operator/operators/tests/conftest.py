from os import getenv

import pytest
from kubernetes.client import ApiClient
from kubernetes.dynamic import DynamicClient

from clients.k8s.k8s_client import KubernetesClient
from clients.rabbit.rabbitclient import AbstractRabbitClient, RabbitClient
from clients.sentry.factories import SentryClientFactory
from clients.sentry.sentryclient import AbstractSentryClient
from clients.vault.factory import VaultClientFactory
from clients.vault.vaultclient import AbstractVaultClient
from utils.passgen import generate_password as strgen


@pytest.fixture(scope="session")
def k8s() -> ApiClient:
    KubernetesClient.configure_kubernetes()
    with ApiClient() as api:
        yield api


@pytest.fixture(scope="session")
def vault() -> AbstractVaultClient:
    vault = VaultClientFactory.create_vault_client()
    yield vault


@pytest.fixture(scope="session")
def sentry() -> AbstractSentryClient:
    host = getenv('REAL_IP')
    sentry = SentryClientFactory.create_sentry_client(sentry_url=f"http://{host}:9000")
    yield sentry


@pytest.fixture(scope="session")
def rabbit() -> AbstractRabbitClient:
    host = getenv('REAL_IP')
    rabbit = RabbitClient(url=f"http://{host}:15672", user="guest", password="guest")
    yield rabbit


@pytest.fixture
def app_name() -> str:
    """Returns generating application name"""
    return strgen(length=6, chars='abcdefghjklmnpqrstuvwxyz')


@pytest.fixture
def deploy_app(k8s, app_manifests):
    client = DynamicClient(k8s)
    for m in app_manifests:
        resource = client.resources.get(
            api_version=m["apiVersion"],
            kind=m["kind"],
        )
        namespace = m.get('metadata', {}).get('namespace')
        client.create(resource, body=m, namespace=namespace)
    yield
    for m in app_manifests:
        resource = client.resources.get(
            api_version=m["apiVersion"],
            kind=m["kind"],
        )
        name = m.get('metadata', {}).get('name')
        namespace = m.get('metadata', {}).get('namespace')
        client.delete(resource, name=name, namespace=namespace)


@pytest.fixture
def create_secrets(vault, app_secrets):
    for path, secret in app_secrets.items():
        vault.create_secret(path, secret)
    yield
    for path in app_secrets.keys():
        vault.delete_secret_all_versions(path)
