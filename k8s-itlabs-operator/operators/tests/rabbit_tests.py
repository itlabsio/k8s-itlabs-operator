import os
import time
from os import getenv
from typing import List, Dict
from unittest import mock

import pytest
from kubernetes.client import CoreV1Api, V1Pod, V1Container, AppsV1Api, ApiException, V1PodList
from kubernetes.dynamic import DynamicClient

from connectors.rabbit_connector import specifications

APP_DEPLOYMENT_NAMESPACE = "default"
RABBIT_VAULT_SECRET_PATH = "vault:secret/data/rabbit-credentials"
REQUIRED_VAULT_SECRET_KEYS = {
    vault_key
    for env_name, vault_key
    in specifications.RABBIT_VAR_NAMES
}
REQUIRED_POD_ENVIRONMENTS = {
    env_name
    for env_name, vault_key
    in specifications.RABBIT_VAR_NAMES
}

RABBIT_HOST = getenv('RABBIT_HOST')


def get_rabbit_instance_name():
    return os.getenv("RABBIT_INSTANCE_NAME", "rabbit")


@pytest.fixture
def app_secrets(app_name) -> Dict[str, dict]:
    # Used by fixture `create_secrets` (see conftest.py)
    return {
        f"vault:secret/data/{app_name}/rabbit-credentials": {
            "BROKER_HOST": RABBIT_HOST,
            "BROKER_PORT": "5672",
            "BROKER_USER": app_name,
            "BROKER_PASSWORD": app_name,
            "BROKER_VHOST": app_name,
            "BROKER_URL": f"amqp://{app_name}:{app_name}@{RABBIT_HOST}:5672/{app_name}",
        }
    }


@pytest.fixture
def app_manifests(app_name) -> List[dict]:
    return [{
        "apiVersion": "apps/v1",
        "kind": "Deployment",
        "metadata": {
            "labels": {
                "app": app_name,
            },
            "name": app_name,
            "namespace": APP_DEPLOYMENT_NAMESPACE,
        },
        "spec": {
            "replicas": 1,
            "selector": {
                "matchLabels": {
                    "app": app_name,
                },
            },
            "template": {
                "metadata": {
                    "labels": {
                        "app": app_name,
                    },
                    "annotations": {
                        "rabbit.connector.itlabs.io/instance-name": get_rabbit_instance_name(),
                        "rabbit.connector.itlabs.io/vault-path": f"vault:secret/data/{app_name}/rabbit-credentials",
                        "rabbit.connector.itlabs.io/username": app_name,
                        "rabbit.connector.itlabs.io/vhost": app_name,
                    },
                },
                "spec": {
                    "containers": [
                        {
                            "image": "alpine:3.15",
                            "name": "alpine",
                            "command": ["/bin/sh", "-c", "while true; do sleep 10000; done"],
                        }
                    ]
                },
            },
        },
    }]


@pytest.fixture
def wait_app_deployment(k8s, app_manifests):
    manifest = app_manifests[0]

    deadline = time.time() + 100
    while time.time() < deadline:
        try:
            deployment_status = AppsV1Api(k8s).read_namespaced_deployment_status(
                namespace=manifest["metadata"]["namespace"],
                name=manifest["metadata"]["name"]
            )
            if deployment_status.status.available_replicas == 1:
                break
            time.sleep(5)
        except ApiException:
            pass
    else:
        pytest.fail("Applying deployment time out")


@pytest.fixture(scope="session")
def rabbit_secret() -> dict:
    return {
        "API_USER": "guest",
        "API_PASSWORD": "guest",
    }


@pytest.fixture(scope="session")
def rabbit_cr() -> dict:
    """Rabbit Custom Resource"""
    return {
        "apiVersion": "itlabs.io/v1",
        "kind": "RabbitConnector",
        "metadata": {
            "name": get_rabbit_instance_name(),
        },
        "spec": {
            "brokerHost": RABBIT_HOST,
            "brokerPort": 5672,
            "url": f"http://{RABBIT_HOST}:15672",
            "username": f"{RABBIT_VAULT_SECRET_PATH}#API_USER",
            "password": f"{RABBIT_VAULT_SECRET_PATH}#API_PASSWORD",
        },
    }


@pytest.fixture(scope="session", autouse=True)
def create_rabbit_cr(k8s, vault, rabbit_secret, rabbit_cr):
    vault.create_secret(
        RABBIT_VAULT_SECRET_PATH,
        rabbit_secret
    )

    resource = DynamicClient(k8s).resources.get(
        api_version="itlabs.io/v1",
        kind="RabbitConnector",
    )
    resource.create(body=rabbit_cr)


@pytest.mark.e2e
@pytest.mark.usefixtures("deploy_app", "wait_app_deployment")
def test_rabbit_operator_on_initial_deployment_application(k8s, vault, rabbit, app_name):
    # Application manifest contains environments:
    #   - BROKER_HOST
    #   - BROKER_PORT
    #   - BROKER_LOGIN
    #   - BROKER_PASSWORD
    #   - BROKER_VHOST
    #   - BROKER_URL
    pod_list: V1PodList = CoreV1Api(k8s).list_namespaced_pod(
        namespace=APP_DEPLOYMENT_NAMESPACE,
        label_selector=f"app={app_name}",
        watch=False
    )
    pods: List[V1Pod] = pod_list.items
    for p in pods:
        containers: List[V1Container] = (
            p.spec.containers +
            (p.spec.init_containers or [])
        )
        for c in containers:
            retrieved_pod_environments = {env.name for env in c.env}
            assert REQUIRED_POD_ENVIRONMENTS <= retrieved_pod_environments

    # Secret was created in Vault by path VAULT_APPLICATION_SECRET_PATH
    # with keys:
    #   - BROKER_HOST
    #   - BROKER_PORT
    #   - BROKER_USER
    #   - BROKER_PASSWORD
    #   - BROKER_VHOST
    #   - BROKER_URL
    secret = vault.read_secret(f"vault:secret/data/{app_name}/rabbit-credentials")
    retrieved_secret_keys = set(secret.keys())
    assert REQUIRED_VAULT_SECRET_KEYS <= retrieved_secret_keys

    # User and vhost were created in Rabbit.
    assert rabbit.get_rabbit_user(user=secret["BROKER_USER"]) is not None
    assert rabbit.get_rabbit_vhost(vhost=secret["BROKER_VHOST"]) is not None
    assert rabbit.get_user_vhost_permissions(
        user=secret["BROKER_USER"],
        vhost=secret["BROKER_VHOST"]
    ) is not None


@pytest.mark.e2e
@pytest.mark.usefixtures("create_secrets", "deploy_app", "wait_app_deployment")
def test_rabbit_operator_on_redeployment_application(k8s, app_name):
    # Application manifest contains environments:
    #   - BROKER_HOST
    #   - BROKER_PORT
    #   - BROKER_LOGIN
    #   - BROKER_PASSWORD
    #   - BROKER_VHOST
    #   - BROKER_URL
    pod_list: V1PodList = CoreV1Api(k8s).list_namespaced_pod(
        namespace=APP_DEPLOYMENT_NAMESPACE,
        label_selector=f"app={app_name}",
        watch=False
    )
    pods: List[V1Pod] = pod_list.items
    for p in pods:
        containers: List[V1Container] = (
            p.spec.containers +
            (p.spec.init_containers or [])
        )
        for c in containers:
            retrieved_pod_environments = {env.name for env in c.env}
            assert REQUIRED_POD_ENVIRONMENTS <= retrieved_pod_environments


@pytest.fixture
def use_non_exist_instance():
    with mock.patch.dict(os.environ, {"RABBIT_INSTANCE_NAME": "non-exist-instance"}):
        yield


@pytest.mark.e2e
@pytest.mark.usefixtures("use_non_exist_instance", "deploy_app", "wait_app_deployment")
def test_rabbit_operator_on_deployment_using_non_exist_custom_resource(k8s, vault, app_name):
    # Application manifest contains environments:
    #   - BROKER_HOST
    #   - BROKER_PORT
    #   - BROKER_LOGIN
    #   - BROKER_PASSWORD
    #   - BROKER_VHOST
    #   - BROKER_URL
    pod_list: V1PodList = CoreV1Api(k8s).list_namespaced_pod(
        namespace=APP_DEPLOYMENT_NAMESPACE,
        label_selector=f"app={app_name}",
        watch=False
    )
    pods: List[V1Pod] = pod_list.items
    for p in pods:
        containers: List[V1Container] = (
                p.spec.containers +
                (p.spec.init_containers or [])
        )
        for c in containers:
            retrieved_pod_environments = {env.name for env in c.env}
            assert REQUIRED_POD_ENVIRONMENTS <= retrieved_pod_environments

    # But secret was not created
    secret = vault.read_secret(f"vault:secret/data/{app_name}/rabbit-credentials")
    assert secret is None

