import os
import time
from os import getenv
from typing import List
from unittest import mock

import pytest
from kubernetes.client import AppsV1Api, ApiException, V1Pod, CoreV1Api, \
    EventsV1Api, V1Container
from kubernetes.dynamic import DynamicClient

from connectors.sentry_connector import specifications


SENTRY_HOST = getenv('REAL_IP')
SENTRY_URL = f"http://{SENTRY_HOST}:9000"
SENTRY_TOKEN = getenv("SENTRY_TOKEN")
SENTRY_ORGANIZATION = getenv("SENTRY_ORGANIZATION")
SENTRY_VAULT_SECRET_PATH = "vault:secret/data/sentry-credentials"

APP_REPLICAS = 2
APP_DEPLOYMENT_NAMESPACE = "default"
APP_DEPLOYMENT_ENVIRONMENT = "production"
APP_DEPLOYMENT_ENVIRONMENT_SHORT = "prod"
REQUIRED_VAULT_SECRET_KEYS = {
    specifications.SENTRY_DSN_KEY,
    specifications.SENTRY_PROJECT_SLUG_KEY,
}
REQUIRED_POD_ENVIRONMENTS = {
    specifications.SENTRY_DSN_KEY,
}


def get_sentry_instance_name():
    return os.getenv("SENTRY_INSTANCE_NAME", "sentry")


@pytest.fixture
def app_manifests(app_name) -> List[dict]:
    return [{
        "apiVersion": "apps/v1",
        "kind": "Deployment",
        "metadata": {
            "labels": {
                "app": app_name,
                "environment": APP_DEPLOYMENT_ENVIRONMENT,
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
                        "sentry.connector.itlabs.io/instance-name": get_sentry_instance_name(),
                        "sentry.connector.itlabs.io/environment": APP_DEPLOYMENT_ENVIRONMENT,
                        "sentry.connector.itlabs.io/vault-path": f"vault:secret/data/{app_name}/sentry-credentials",
                        "sentry.connector.itlabs.io/project": app_name,
                        "sentry.connector.itlabs.io/team": app_name,
                    },
                },
                "spec": {
                    "containers": [
                        {
                            "image": "alpine:3.15",
                            "name": "sentry-alpine",
                            "command": ["/bin/sh", "-c", "while true; do sleep 10000; done"],
                        }
                    ]
                },
            },
        },
    }]


@pytest.fixture
def wait_app_deployments(k8s, app_manifests):
    manifest = app_manifests[0]

    deadline = time.time() + 25
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
def sentry_cr() -> dict:
    """Sentry Custom Resource"""

    return {
        "apiVersion": "itlabs.io/v1",
        "kind": "SentryConnector",
        "metadata": {
            "name": get_sentry_instance_name(),
        },
        "spec": {
            "url": SENTRY_URL,
            "token": f"{SENTRY_VAULT_SECRET_PATH}#{specifications.SENTRY_API_TOKEN_KEY}",
        },
    }


@pytest.fixture(scope="session", autouse=True)
def create_sentry_cr(k8s, vault, sentry_cr):
    vault.create_secret(
        SENTRY_VAULT_SECRET_PATH,
        {
            specifications.SENTRY_API_TOKEN_KEY: SENTRY_TOKEN,
        }
    )

    resource = DynamicClient(k8s).resources.get(
        api_version="itlabs.io/v1",
        kind="SentryConnector",
    )
    resource.create(body=sentry_cr)


@pytest.fixture
def prepare_sentry_project(sentry, vault, app_name):
    team = sentry.create_sentry_team(team_name=app_name, team_slug=app_name)
    project = sentry.create_sentry_project(team_slug=team.slug, project_name=app_name)
    project_key = sentry.create_sentry_project_key(project_slug=project.slug, key_name=APP_DEPLOYMENT_ENVIRONMENT_SHORT)

    vault.create_secret(
        f"vault:secret/data/{app_name}/sentry-credentials",
        {
            "SENTRY_DSN": project_key.dsn,
            "SENTRY_PROJECT_SLUG": project.slug,
        }
    )


@pytest.fixture
def cleanup_sentry_project(sentry, app_name):
    # Team and project are required to remove in external Sentry after testing.
    yield
    sentry.delete_sentry_project(app_name)
    sentry.delete_sentry_team(app_name)


@pytest.mark.e2e
@pytest.mark.usefixtures("deploy_app", "wait_app_deployments", "cleanup_sentry_project")
def test_sentry_operator_on_initial_deployment_application(k8s, vault, sentry, app_name):
    # Application manifest contains environments:
    #   - SENTRY_DSN
    pods: List[V1Pod] = CoreV1Api(k8s).list_namespaced_pod(
        namespace=APP_DEPLOYMENT_NAMESPACE,
        label_selector=f"app={app_name}",
        watch=False,
    ).items
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
    #   - SENTRY_DSN
    #   - SENTRY_PROJECT_SLUG
    secret = vault.read_secret(f"vault:secret/data/{app_name}/sentry-credentials")
    retrieved_secret_keys = set(secret.keys())
    assert REQUIRED_VAULT_SECRET_KEYS <= retrieved_secret_keys

    # Team, project and DSN key will be created.
    sentry.get_sentry_team(app_name)
    sentry.get_sentry_project(app_name)
    keys = sentry.get_sentry_project_keys(app_name)
    assert len(keys) > 0
    assert any(
        k.name == specifications.SENTRY_TRANSFORM_ENVIRONMENTS[APP_DEPLOYMENT_ENVIRONMENT]
        and k.dsn == secret[specifications.SENTRY_DSN_KEY]
        for k in keys
    )


@pytest.mark.e2e
@pytest.mark.usefixtures("prepare_sentry_project", "deploy_app", "wait_app_deployments", "cleanup_sentry_project")
def test_sentry_operator_on_redeployment_application(k8s, vault, app_name):
    # Application manifest contains environments:
    #   - SENTRY_DSN
    pods: List[V1Pod] = CoreV1Api(k8s).list_namespaced_pod(
        namespace=APP_DEPLOYMENT_NAMESPACE,
        label_selector=f"app={app_name}",
        watch=False,
    ).items
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
    with mock.patch.dict(os.environ, {"SENTRY_INSTANCE_NAME": "non-exist-instance"}):
        yield


@pytest.mark.e2e
@pytest.mark.usefixtures("use_non_exist_instance", "deploy_app", "wait_app_deployments")
def test_sentry_operator_on_deployment_using_non_exist_custom_resource(k8s, vault, app_name):
    # Application manifest does not contain environments:
    #   - SENTRY_DSN
    pods: List[V1Pod] = CoreV1Api(k8s).list_namespaced_pod(
        namespace=APP_DEPLOYMENT_NAMESPACE,
        label_selector=f"app={app_name}",
        watch=False,
    ).items
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
    secret = vault.read_secret(f"vault:secret/data/{app_name}/sentry-credentials")
    assert secret is None

    # Event was created
    events = EventsV1Api(k8s).list_namespaced_event(
        namespace=APP_DEPLOYMENT_NAMESPACE,
        field_selector="reason=SentryConnector"
    )
    assert any(
        event.type == "Error"
        and event.reason == "SentryConnector"
        and event.note == "Sentry Connector not applied"
        and app_name in event.regarding.name
        for event in events.items
    )
