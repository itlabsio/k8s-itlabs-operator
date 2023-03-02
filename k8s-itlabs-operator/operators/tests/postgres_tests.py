import time
from os import getenv
from typing import List, Dict

import pytest
import psycopg2
from kubernetes.client import AppsV1Api, CoreV1Api, V1Pod, V1Container, ApiException, V1PodList
from kubernetes.dynamic import DynamicClient

from connectors.postgres_connector import specifications

APP_DEPLOYMENT_NAMESPACE = "default"
POSTGRES_INSTANCE_NAME = "postgres"
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
                        "postgres.connector.itlabs.io/instance-name": POSTGRES_INSTANCE_NAME,
                        "postgres.connector.itlabs.io/vault-path": f"vault:secret/data/{app_name}/postgres-credentials",
                        "postgres.connector.itlabs.io/db-name": app_name,
                        "postgres.connector.itlabs.io/db-username": app_name,
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
def pg_secret() -> dict:
    return {
        "DATABASE_USER": "operator",
        "DATABASE_PASSWORD": "operator_pwd",
    }


@pytest.fixture(scope="session")
def pg_cr() -> dict:
    """Postgres Custom Resource"""
    return {
        "apiVersion": "itlabs.io/v1",
        "kind": "PostgresConnector",
        "metadata": {
            "name": POSTGRES_INSTANCE_NAME,
        },
        "spec": {
            "host": POSTGRES_HOST,
            "database": "postgres",
            "username": f"{POSTGRES_VAULT_SECRET_PATH}#DATABASE_USER",
            "password": f"{POSTGRES_VAULT_SECRET_PATH}#DATABASE_PASSWORD",
        },
    }


@pytest.fixture(scope="session", autouse=True)
def create_postgres_cr(k8s, vault, pg_secret, pg_cr):
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


@pytest.mark.e2e
@pytest.mark.usefixtures("deploy_app", "wait_app_deployment")
def test_postgres_operator_on_initial_deployment_application(k8s, vault, app_name):
    # Application manifest contains environments:
    #   - POSTGRES_DB_HOST
    #   - POSTGRES_DB_PORTApiException
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
