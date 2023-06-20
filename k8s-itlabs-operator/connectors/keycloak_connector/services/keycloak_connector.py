import logging
from itertools import chain

from connectors.keycloak_connector import specifications
from connectors.keycloak_connector.dto import KeycloakConnectorMicroserviceDto
from connectors.keycloak_connector.exceptions import KeycloakConnectorCrdDoesNotExist, \
    NonExistSecretForKeycloakConnector
from connectors.keycloak_connector.factories.service_factories.keycloak import KeycloakServiceFactory
from connectors.keycloak_connector.services.kubernetes import KubernetesService
from connectors.keycloak_connector.services.vault import VaultService
from connectors.keycloak_connector.specifications import \
    KEYCLOAK_CONNECTOR_REQUIRED_ANNOTATIONS as REQUIRED_ANNOTATIONS
from utils.concurrency import ConnectorSourceLock
from utils.hashing import generate_hash


class KeycloakConnectorService:
    def __init__(self, vault_service: VaultService):
        self.vault_service = vault_service

    @staticmethod
    def is_kk_conn_used_by_obj(annotations: dict) -> bool:
        has_required_annotations = all(
            map(lambda x: x in annotations, REQUIRED_ANNOTATIONS)
        )
        return has_required_annotations

    @staticmethod
    def containers_contain_required_envs(spec: dict) -> bool:
        all_containers = chain(
            spec.get("containers", []),
            spec.get("initContainers", [])
        )

        for container in all_containers:
            for env_name, _ in specifications.KEYCLOAK_VAR_NAMES:
                envs = [e.get("name") for e in container.get("env", {})]
                if env_name not in envs:
                    return False
        return True

    def on_create_deployment(self, ms_kk_conn: KeycloakConnectorMicroserviceDto):
        kk_connector = KubernetesService.get_keycloak_connector(ms_kk_conn.keycloak_instance_name)
        if not kk_connector:
            raise KeycloakConnectorCrdDoesNotExist(
                f"Keycloak Custom Resource `{ms_kk_conn.keycloak_instance_name}`"
                " does not exist"
            )

        kk_api_cred = self.vault_service.unvault_keycloak_connector(kk_connector)
        if not kk_api_cred:
            raise NonExistSecretForKeycloakConnector(
                "Couldn't getting root credentials for connecting to Keycloak"
            )

        kk_service = KeycloakServiceFactory.create(
            url=kk_api_cred.url, realm=kk_api_cred.realm,
            username=kk_api_cred.username, password=kk_api_cred.password
        )
        kk_ms_cred = self.vault_service.get_kk_ms_secret(ms_kk_conn.vault_path)

        source_hash = self.generate_source_hash(
            url=kk_api_cred.url,
            realm=kk_api_cred.realm,
            client_id=ms_kk_conn.client_id,
        )
        with ConnectorSourceLock(source_hash):
            if kk_ms_cred and kk_service.is_kk_client_exist(client_id=ms_kk_conn.client_id):
                logging.info("Keycloak client already exist")
                return

            kk_ms_cred = kk_service.configure_kk(ms_kk_conn)
            self.vault_service.create_kk_ms_secret(ms_kk_conn.vault_path, kk_ms_cred)

    @staticmethod
    def generate_source_hash(url: str, realm: str, client_id) -> str:
        return generate_hash(url, realm, client_id)

    def mutate_containers(self, spec, ms_keycloak_conn: KeycloakConnectorMicroserviceDto) -> bool:
        mutated = False
        for container in spec.get("containers", []):
            mutated = self.mutate_container(container, mutated, ms_keycloak_conn.vault_path)
        for init_container in spec.get("initContainers", []):
            mutated = self.mutate_container(init_container, mutated, ms_keycloak_conn.vault_path)
        return mutated

    def mutate_container(self, container: dict, mutated: bool, vault_path: str) -> bool:
        envs = container.get("env", [])
        env_names = {e.get("name") for e in envs}
        for env_name, vault_key in specifications.KEYCLOAK_VAR_NAMES:
            if env_name not in env_names:
                envs.append({
                    "name": env_name,
                    "value": self.vault_service.get_vault_env_value(
                        vault_path, vault_key
                    )
                })
                mutated = True
        if mutated:
            container["env"] = envs
        return mutated
