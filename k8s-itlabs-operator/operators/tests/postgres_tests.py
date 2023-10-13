import os
import time
from os import getenv
from typing import List, Dict
from unittest import mock

import pytest
import psycopg2
from kubernetes.client import AppsV1Api, CoreV1Api, V1Pod, V1Container, \
    EventsV1Api, ApiException, V1PodList
from kubernetes.dynamic import DynamicClient

from connectors.postgres_connector import specifications


APP_REPLICAS = 2
APP_DEPLOYMENT_NAMESPACE = "default"
POSTGRES_VAULT_SECRET_PATH = "vault:secret/data/postgres-credentials"
REQUIRED_VAULT_SECRET_KEYS = {
    vault_key
    for env_name, vault_key
    in specifications.DATABASE_VAR_NAMES
}
REQUIRED_POD_ENVIRONMENTS = {
    env_name
    for env_name, vault_key
    in specifications.DATABASE_VAR_NAMES
}

POSTGRES_HOST = getenv('POSTGRES_HOST')
POSTGRES_INSTANCE_NAME = "postgres"
POSTGRES_READONLY_USERNAME = "readonly"


def get_postgres_instance_name():
    return os.getenv("POSTGRES_INSTANCE_NAME", POSTGRES_INSTANCE_NAME)


def get_postgres_instance_name_without_readonly():
    return f"{get_postgres_instance_name()}-without-ro"


def get_postgres_instance_name_with_non_exist_readonly():
    return f"{get_postgres_instance_name()}-with-non-exist-ro"


def get_postgres_readonly_username():
    return os.getenv(
        "POSTGRES_READONLY_USERNAME",
        POSTGRES_READONLY_USERNAME
    )


@pytest.fixture
def app_secrets(app_name) -> Dict[str, dict]:
    # Used by fixture `create_secrets` (see conftest.py)
    return {
        f"vault:secret/data/{app_name}/postgres-credentials": {
            "DATABASE_HOST": f"{POSTGRES_HOST}",
            "DATABASE_PORT": 5432,
            "DATABASE_NAME": app_name,
            "DATABASE_USER": app_name,
            "DATABASE_PASSWORD": app_name,
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
            "replicas": APP_REPLICAS,
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
                        "postgres.connector.itlabs.io/instance-name": get_postgres_instance_name(),
                        "postgres.connector.itlabs.io/vault-path": f"vault:secret/data/{app_name}/postgres-credentials",
                        "postgres.connector.itlabs.io/db-name": app_name,
                        "postgres.connector.itlabs.io/db-username": app_name,
                        "postgres.connector.itlabs.io/grant-access-for-readonly-user": "true",
                    },
                },
                "spec": {
                    "containers": [
                        {
                            "image": "alpine:3.15",
                            "name": "postgres-alpine",
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
            if deployment_status.status.available_replicas == APP_REPLICAS:
                break
            time.sleep(5)
        except ApiException:
            pass
    else:
        pytest.fail("Applying deployment time out")


@pytest.fixture(scope="session")
def pg_secret() -> dict:
    return {
        "DATABASE_USER": "operator",
        "DATABASE_PASSWORD": "operator_pwd",
        "DATABASE_READONLY_USER": get_postgres_readonly_username(),
        "DATABASE_NON_EXIST_READONLY_USER": f"{get_postgres_readonly_username()}-non-exist",
    }


@pytest.fixture(scope="session")
def pg_cr() -> dict:
    """Postgres Custom Resource"""
    return {
        "apiVersion": "itlabs.io/v1",
        "kind": "PostgresConnector",
        "metadata": {
            "name": get_postgres_instance_name(),
        },
        "spec": {
            "host": POSTGRES_HOST,
            "username": f"{POSTGRES_VAULT_SECRET_PATH}#DATABASE_USER",
            "password": f"{POSTGRES_VAULT_SECRET_PATH}#DATABASE_PASSWORD",
            "readonly-username": f"{POSTGRES_VAULT_SECRET_PATH}#DATABASE_READONLY_USER",
        },
    }


@pytest.fixture(scope="session")
def pg_cr_without_readonly() -> dict:
    """Postgres Custom Resource that does not contain readonly role"""
    return {
        "apiVersion": "itlabs.io/v1",
        "kind": "PostgresConnector",
        "metadata": {
            "name": get_postgres_instance_name_without_readonly(),
        },
        "spec": {
            "host": POSTGRES_HOST,
            "username": f"{POSTGRES_VAULT_SECRET_PATH}#DATABASE_USER",
            "password": f"{POSTGRES_VAULT_SECRET_PATH}#DATABASE_PASSWORD",
        },
    }


@pytest.fixture(scope="session")
def pg_cr_with_non_exist_readonly() -> dict:
    """Postgres Custom Resource that contains non exist readonly role"""
    return {
        "apiVersion": "itlabs.io/v1",
        "kind": "PostgresConnector",
        "metadata": {
            "name": get_postgres_instance_name_with_non_exist_readonly(),
        },
        "spec": {
            "host": POSTGRES_HOST,
            "username": f"{POSTGRES_VAULT_SECRET_PATH}#DATABASE_USER",
            "password": f"{POSTGRES_VAULT_SECRET_PATH}#DATABASE_PASSWORD",
            "readonly-username": f"{POSTGRES_VAULT_SECRET_PATH}#DATABASE_NON_EXIST_READONLY_USER",
        },
    }


@pytest.fixture(scope="session", autouse=True)
def create_postgres_cr(
        k8s, vault, pg_secret,
        pg_cr, pg_cr_without_readonly, pg_cr_with_non_exist_readonly
):
    secret = vault.read_secret(POSTGRES_VAULT_SECRET_PATH)
    if not secret:
        vault.create_secret(
            POSTGRES_VAULT_SECRET_PATH,
            pg_secret
        )

    resource = DynamicClient(k8s).resources.get(
        api_version="itlabs.io/v1",
        kind="PostgresConnector",
    )
    resource.create(body=pg_cr)
    resource.create(body=pg_cr_without_readonly)
    resource.create(body=pg_cr_with_non_exist_readonly)


@pytest.mark.e2e
@pytest.mark.usefixtures("deploy_app", "wait_app_deployment")
def test_postgres_operator_on_initial_deployment_application(k8s, vault, app_name):
    # Application manifest contains environments:
    #   - POSTGRES_DB_HOST
    #   - POSTGRES_DB_PORT
    #   - POSTGRES_DB_NAME
    #   - POSTGRES_DB_USER
    #   - POSTGRES_DB_PASSWORD
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
    #   - DATABASE_HOST
    #   - DATABASE_PORT
    #   - DATABASE_NAME
    #   - DATABASE_USER
    #   - DATABASE_PASSWORD
    secret = vault.read_secret(f"vault:secret/data/{app_name}/postgres-credentials")
    retrieved_secret_keys = set(secret.keys())
    assert REQUIRED_VAULT_SECRET_KEYS <= retrieved_secret_keys

    # DB was created in Postgres.
    psycopg2.connect(
        host=secret["DATABASE_HOST"],
        port=secret["DATABASE_PORT"],
        user=secret["DATABASE_USER"],
        password=secret["DATABASE_PASSWORD"],
        dbname=secret["DATABASE_NAME"],
    )

    # Events does not exist
    events = EventsV1Api(k8s).list_namespaced_event(
        namespace=APP_DEPLOYMENT_NAMESPACE,
        field_selector="reason=PostgresConnector"
    )
    assert not any(
        event.reason == "PostgresConnector"
        and app_name in event.regarding.name
        for event in events.items
    )


@pytest.mark.e2e
@pytest.mark.usefixtures("create_secrets", "deploy_app", "wait_app_deployment")
def test_postgres_operator_on_redeployment_application(k8s, app_name):
    # Application manifest contains environments:
    #   - POSTGRES_DB_HOST
    #   - POSTGRES_DB_PORT
    #   - POSTGRES_DB_NAME
    #   - POSTGRES_DB_USER
    #   - POSTGRES_DB_PASSWORD
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

    # Events does not exist
    events = EventsV1Api(k8s).list_namespaced_event(
        namespace=APP_DEPLOYMENT_NAMESPACE,
        field_selector="reason=PostgresConnector"
    )
    assert not any(
        event.reason == "PostgresConnector"
        and app_name in event.regarding.name
        for event in events.items
    )


@pytest.fixture
def use_non_exist_instance():
    with mock.patch.dict(os.environ, {"POSTGRES_INSTANCE_NAME": "non-exist-instance"}):
        yield


@pytest.mark.e2e
@pytest.mark.usefixtures("use_non_exist_instance", "deploy_app", "wait_app_deployment")
def test_postgres_operator_on_deployment_using_non_exist_custom_resource(k8s, vault, app_name):
    # Application manifest does not contain environments:
    #   - POSTGRES_DB_HOST
    #   - POSTGRES_DB_PORT
    #   - POSTGRES_DB_NAME
    #   - POSTGRES_DB_USER
    #   - POSTGRES_DB_PASSWORD
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
            environments = c.env or []
            retrieved_pod_environments = {env.name for env in environments}
            assert REQUIRED_POD_ENVIRONMENTS not in retrieved_pod_environments

    # Secret was not created
    secret = vault.read_secret(f"vault:secret/data/{app_name}/postgres-credentials")
    assert secret is None

    # Event was created
    events = EventsV1Api(k8s).list_namespaced_event(
        namespace=APP_DEPLOYMENT_NAMESPACE,
        field_selector="reason=PostgresConnector"
    )
    assert any(
        event.type == "Error"
        and event.reason == "PostgresConnector"
        and "Postgres Custom Resource `non-exist-instance` does not exist" in event.note
        and app_name in event.regarding.name
        for event in events.items
    )


@pytest.fixture
def use_instance_without_readonly_username():
    envs = {
        "POSTGRES_INSTANCE_NAME": get_postgres_instance_name_without_readonly(),
    }
    with mock.patch.dict(os.environ, envs):
        yield


@pytest.mark.e2e
@pytest.mark.usefixtures("use_instance_without_readonly_username", "deploy_app", "wait_app_deployment")
def test_test_postgres_operator_on_deployment_using_custom_resource_without_readonly(k8s, app_name):
    # Event was created
    events = EventsV1Api(k8s).list_namespaced_event(
        namespace=APP_DEPLOYMENT_NAMESPACE,
        field_selector="reason=PostgresConnector"
    )
    assert any(
        event.type == "Error"
        and event.reason == "PostgresConnector"
        and ("Username for readonly access to the database is not set in "
             "Custom Resource `postgres-without-ro` for Postgres") in event.note
        and app_name in event.regarding.name
        for event in events.items
    )


@pytest.fixture
def use_instance_contain_non_exist_readonly_username():
    envs = {
        "POSTGRES_INSTANCE_NAME": get_postgres_instance_name_with_non_exist_readonly(),
    }
    with mock.patch.dict(os.environ, envs):
        yield


@pytest.mark.e2e
@pytest.mark.usefixtures("use_instance_contain_non_exist_readonly_username", "deploy_app", "wait_app_deployment")
def test_test_postgres_operator_on_deployment_using_custom_resource_contain_non_exist_readonly(k8s, app_name):
    # Event was created
    events = EventsV1Api(k8s).list_namespaced_event(
        namespace=APP_DEPLOYMENT_NAMESPACE,
        field_selector="reason=PostgresConnector"
    )
    assert any(
        event.type == "Error"
        and event.reason == "PostgresConnector"
        and ("Username for readonly access to the database does not exist "
             "in `postgres-with-non-exist-ro`") in event.note
        and app_name in event.regarding.name
        for event in events.items
    )
