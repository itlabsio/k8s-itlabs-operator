import os
import time
from os import getenv
from typing import List, Optional
from unittest import mock

import pytest
import requests
from clients.keycloak.client import KeycloakClient
from clients.keycloak.dto import ClientDto
from connectors.keycloak_connector import specifications
from kubernetes.client import (
    ApiException,
    AppsV1Api,
    CoreV1Api,
    EventsV1Api,
    V1Container,
    V1Pod,
)
from kubernetes.dynamic import DynamicClient

KEYCLOAK_HOST = getenv("KEYCLOAK_HOST")
KEYCLOAK_API_URL = f"http://{KEYCLOAK_HOST}:8080"

KEYCLOAK_ROOT_REALM = "master"
KEYCLOAK_ROOT_USERNAME = getenv("KEYCLOAK_ROOT_USERNAME")
KEYCLOAK_ROOT_PASSWORD = getenv("KEYCLOAK_ROOT_PASSWORD")

KEYCLOAK_REALM = "test-realm"
KEYCLOAK_REALM_USERNAME = "test-user"
KEYCLOAK_REALM_PASSWORD = "test-password"

VAULT_KEYCLOAK_USER_SECRET_PATH = "vault:secret/data/keycloak-credentials"

APP_REPLICAS = 2
APP_DEPLOYMENT_NAMESPACE = "default"
REQUIRED_POD_ENVIRONMENTS = {
    env_name for env_name, _ in specifications.KEYCLOAK_VAR_NAMES
}
REQUIRED_VAULT_SECRET_KEYS = {
    vault_key for _, vault_key in specifications.KEYCLOAK_VAR_NAMES
}

# Keycloak url templates

URL_ADMIN_REALM = "admin/realms"
URL_ADMIN_USERS = "admin/realms/{realm}/users"
URL_ADMIN_USER = "admin/realms/{realm}/users?username={username}"
URL_ADMIN_CLIENTS = "admin/realms/{realm}/clients?clientId={client}"
URL_ADMIN_CLIENT_ROLE = (
    "admin/realms/{realm}/clients/{client_id}/roles?search={role}"
)
URL_ADMIN_ASSIGN_USER_ROLE_MAPPING = (
    "admin/realms/{realm}/users/{user_id}/role-mappings/clients/{client_id}"
)


def get_keycloak_instance_name():
    return os.getenv("KEYCLOAK_INSTANCE_NAME", "keycloak")


class RootKeycloakClient(KeycloakClient):
    def create_realm(self, realm: str):
        path = self._build_path(URL_ADMIN_REALM)
        data = {"id": realm, "realm": realm, "enabled": True}
        requests.post(path, auth=self._get_auth(), json=data)

    def create_realm_user(self, realm: str, username: str, password: str):
        path = self._build_path(URL_ADMIN_USERS.format(realm=realm))
        data = {
            "username": username,
            "enabled": True,
            "credentials": [
                {
                    "type": "password",
                    "value": password,
                    "temporary": False,
                }
            ],
        }
        requests.post(path, auth=self._get_auth(), json=data)

    def get_realm_user_id(self, realm: str, username: str) -> Optional[str]:
        path = self._build_path(
            URL_ADMIN_USER.format(realm=realm, username=username)
        )
        response = requests.get(path, auth=self._get_auth())
        try:
            return response.json()[0]["id"]
        except (IndexError, KeyError):
            pass

    def get_realm_client_id(self, realm: str, client: str) -> Optional[str]:
        path = self._build_path(
            URL_ADMIN_CLIENTS.format(realm=realm, client=client)
        )
        response = requests.get(path, auth=self._get_auth())
        try:
            return response.json()[0]["id"]
        except (IndexError, KeyError):
            pass

    def get_realm_client_role_id(
        self, realm: str, client_id: str, role: str
    ) -> Optional[str]:
        path = self._build_path(
            URL_ADMIN_CLIENT_ROLE.format(
                realm=realm, client_id=client_id, role=role
            )
        )
        response = requests.get(path, auth=self._get_auth())
        try:
            return response.json()[0]["id"]
        except (IndexError, KeyError):
            pass

    def assign_manage_clients_role_for_realm_user(
        self, realm: str, user_id: str
    ):
        client_name = "realm-management"
        role_name = "manage-clients"
        role_description = "${role_manage-clients}"

        client_id = self.get_realm_client_id(realm=realm, client=client_name)
        client_role_id = self.get_realm_client_role_id(
            realm=realm, client_id=client_id, role=role_name
        )

        path = self._build_path(
            URL_ADMIN_ASSIGN_USER_ROLE_MAPPING.format(
                realm=realm, user_id=user_id, client_id=client_id
            )
        )
        data = [
            {
                "id": client_role_id,
                "name": role_name,
                "description": role_description,
                "composite": False,
                "clientRole": True,
                "containerId": client_id,
            }
        ]
        requests.post(path, auth=self._get_auth(), json=data)


@pytest.fixture(scope="session", autouse=True)
def prepare_keycloak():
    root_kk = RootKeycloakClient(
        url=KEYCLOAK_API_URL,
        realm=KEYCLOAK_ROOT_REALM,
        username=KEYCLOAK_ROOT_USERNAME,
        password=KEYCLOAK_ROOT_PASSWORD,
    )

    root_kk.create_realm(KEYCLOAK_REALM)

    root_kk.create_realm_user(
        realm=KEYCLOAK_REALM,
        username=KEYCLOAK_REALM_USERNAME,
        password=KEYCLOAK_REALM_PASSWORD,
    )
    realm_user_id = root_kk.get_realm_user_id(
        realm=KEYCLOAK_REALM,
        username=KEYCLOAK_REALM_USERNAME,
    )

    root_kk.assign_manage_clients_role_for_realm_user(
        realm=KEYCLOAK_REALM,
        user_id=realm_user_id,
    )


@pytest.fixture(scope="session")
def kk_secret() -> dict:
    return {
        "USERNAME": KEYCLOAK_REALM_USERNAME,
        "PASSWORD": KEYCLOAK_REALM_PASSWORD,
    }


@pytest.fixture(scope="session")
def kk_cr() -> dict:
    """Keycloak Custom Resource"""
    return {
        "apiVersion": "itlabs.io/v1",
        "kind": "KeycloakConnector",
        "metadata": {
            "name": get_keycloak_instance_name(),
        },
        "spec": {
            "url": KEYCLOAK_API_URL,
            "realm": KEYCLOAK_REALM,
            "username": f"{VAULT_KEYCLOAK_USER_SECRET_PATH}#USERNAME",
            "password": f"{VAULT_KEYCLOAK_USER_SECRET_PATH}#PASSWORD",
        },
    }


@pytest.fixture(scope="session", autouse=True)
def create_kk_cr(k8s, vault, kk_secret, kk_cr):
    vault.create_secret(VAULT_KEYCLOAK_USER_SECRET_PATH, kk_secret)

    resource = DynamicClient(k8s).resources.get(
        api_version="itlabs.io/v1",
        kind="KeycloakConnector",
    )
    resource.create(body=kk_cr)


@pytest.fixture
def kk():
    return KeycloakClient(
        url=KEYCLOAK_API_URL,
        realm=KEYCLOAK_REALM,
        username=KEYCLOAK_REALM_USERNAME,
        password=KEYCLOAK_REALM_PASSWORD,
    )


@pytest.fixture
def prepare_kk_realm_client(kk, vault, app_name):
    kk.create_client(client=ClientDto(client_id=app_name, name=app_name))
    client = kk.get_client(client_id=app_name)
    secret = kk.generate_secret(client_id=client.id)

    vault.create_secret(
        f"vault:secret/data/{app_name}/keycloak-credentials",
        {
            specifications.KEYCLOAK_CLIENT_ID_KEY: client.client_id,
            specifications.KEYCLOAK_SECRET_KEY: secret,
        },
    )


@pytest.fixture
def app_manifests(app_name) -> List[dict]:
    return [
        {
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
                            "keycloak.connector.itlabs.io/instance-name": get_keycloak_instance_name(),
                            "keycloak.connector.itlabs.io/vault-path": f"vault:secret/data/{app_name}/keycloak-credentials",
                            "keycloak.connector.itlabs.io/client-id": app_name,
                        },
                    },
                    "spec": {
                        "containers": [
                            {
                                "image": "alpine:3.15",
                                "name": "keycloak-alpine",
                                "command": [
                                    "/bin/sh",
                                    "-c",
                                    "while true; do sleep 10000; done",
                                ],
                            }
                        ],
                    },
                },
            },
        }
    ]


@pytest.fixture
def wait_app_deployment(k8s, app_manifests):
    manifest = app_manifests[0]

    deadline = time.time() + 25
    while time.time() < deadline:
        try:
            deployment_status = AppsV1Api(
                k8s
            ).read_namespaced_deployment_status(
                namespace=manifest["metadata"]["namespace"],
                name=manifest["metadata"]["name"],
            )
            if deployment_status.status.available_replicas == APP_REPLICAS:
                break
            time.sleep(5)
        except ApiException:
            pass
    else:
        pytest.fail("Applying deployment time out")


@pytest.mark.e2e
@pytest.mark.usefixtures("deploy_app", "wait_app_deployment")
def test_keycloak_operator_on_initial_deployment_application(
    k8s, kk, vault, app_name
):
    # Application manifest contains environments:
    #   - KEYCLOAK_CLIENT_ID
    #   - KEYCLOAK_SECRET_KEY
    pods: List[V1Pod] = (
        CoreV1Api(k8s)
        .list_namespaced_pod(
            namespace=APP_DEPLOYMENT_NAMESPACE,
            label_selector=f"app={app_name}",
            watch=False,
        )
        .items
    )
    for p in pods:
        containers: List[V1Container] = p.spec.containers + (
            p.spec.init_containers or []
        )
        for c in containers:
            retrieved_pod_environments = {env.name for env in c.env}
            assert REQUIRED_POD_ENVIRONMENTS <= retrieved_pod_environments

    # Secret was created in Vault by path VAULT_APPLICATION_SECRET_PATH
    # with keys:
    #   - KEYCLOAK_CLIENT_ID
    #   - KEYCLOAK_SECRET_KEY
    secret = vault.read_secret(
        f"vault:secret/data/{app_name}/keycloak-credentials"
    )
    retrieved_secret_keys = set(secret.keys())
    assert REQUIRED_VAULT_SECRET_KEYS <= retrieved_secret_keys

    client = kk.get_client(client_id=app_name)
    assert client is not None


@pytest.mark.e2e
@pytest.mark.usefixtures(
    "prepare_kk_realm_client", "deploy_app", "wait_app_deployment"
)
def test_keycloak_operator_on_redeployment_application(k8s, vault, app_name):
    # Application manifest contains environments:
    #   - KEYCLOAK_CLIENT_ID
    #   - KEYCLOAK_SECRET_KEY
    pods: List[V1Pod] = (
        CoreV1Api(k8s)
        .list_namespaced_pod(
            namespace=APP_DEPLOYMENT_NAMESPACE,
            label_selector=f"app={app_name}",
            watch=False,
        )
        .items
    )
    for p in pods:
        containers: List[V1Container] = p.spec.containers + (
            p.spec.init_containers or []
        )
        for c in containers:
            retrieved_pod_environments = {env.name for env in c.env}
            assert REQUIRED_POD_ENVIRONMENTS <= retrieved_pod_environments


@pytest.fixture
def use_non_exist_instance():
    with mock.patch.dict(
        os.environ, {"KEYCLOAK_INSTANCE_NAME": "non-exist-instance"}
    ):
        yield


@pytest.mark.e2e
@pytest.mark.usefixtures(
    "use_non_exist_instance", "deploy_app", "wait_app_deployment"
)
def test_keycloak_operator_on_deployment_using_non_exist_custom_resource(
    k8s, vault, app_name
):
    # Application manifest does not contain environments:
    #   - KEYCLOAK_CLIENT_ID
    #   - KEYCLOAK_SECRET_KEY
    pods: List[V1Pod] = (
        CoreV1Api(k8s)
        .list_namespaced_pod(
            namespace=APP_DEPLOYMENT_NAMESPACE,
            label_selector=f"app={app_name}",
            watch=False,
        )
        .items
    )
    for p in pods:
        containers: List[V1Container] = p.spec.containers + (
            p.spec.init_containers or []
        )
        for c in containers:
            environments = c.env or []
            retrieved_pod_environments = {env.name for env in environments}
            assert REQUIRED_POD_ENVIRONMENTS not in retrieved_pod_environments

    # Secret was not created
    secret = vault.read_secret(
        f"vault:secret/data/{app_name}/keycloak-credentials"
    )
    assert secret is None

    # Event was created
    events = EventsV1Api(k8s).list_namespaced_event(
        namespace=APP_DEPLOYMENT_NAMESPACE,
        field_selector="reason=KeycloakConnector",
    )
    assert any(
        event.type == "Error"
        and event.reason == "KeycloakConnector"
        and event.note
        == "Keycloak Connector not applied for next reasons: Keycloak Custom Resource `non-exist-instance` does not exist"
        and app_name in event.regarding.name
        for event in events.items
    )
