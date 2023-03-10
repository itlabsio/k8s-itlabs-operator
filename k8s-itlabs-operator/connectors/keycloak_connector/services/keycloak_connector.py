import logging
from typing import Optional

from connectors.keycloak_connector import specifications
from connectors.keycloak_connector.dto import KeycloakConnectorMicroserviceDto, \
    KeycloakApiSecretDto, KeycloakConnector
from connectors.keycloak_connector.exceptions import KeycloakConnectorCrdDoesNotExist, \
    NonExistSecretForSentryConnector
from connectors.keycloak_connector.factories.dto_factory import \
    KeycloakApiSecretDtoFactory
from connectors.keycloak_connector.factories.service_factories.keycloak import \
    KeycloakServiceFactory
from connectors.keycloak_connector.services.kubernetes import KubernetesService
from connectors.keycloak_connector.services.vault import VaultService
from connectors.keycloak_connector.specifications import \
    KEYCLOAK_CONNECTOR_REQUIRED_ANNOTATIONS as REQUIRED_ANNOTATIONS


class KeycloakConnectorService:
    def __init__(self, vault_service: VaultService):
        self.vault_service = vault_service

    @staticmethod
    def is_kk_conn_used_by_obj(annotations: dict) -> bool:
        has_required_annotations = all(
            map(lambda x: x in annotations, REQUIRED_ANNOTATIONS)
        )
        return has_required_annotations

    def __get_kk_api_secret(self, kk_conn_crd: KeycloakConnector) -> Optional[KeycloakApiSecretDto]:
        username = self.vault_service.get_kk_api_secret(kk_conn_crd.username_secret)
        password = self.vault_service.get_kk_api_secret(kk_conn_crd.password_secret)

        if not(username and password):
            return None

        return KeycloakApiSecretDtoFactory.create_api_secret_dto(kk_conn_crd, username, password)

    def on_create_deployment(self, ms_kk_conn: KeycloakConnectorMicroserviceDto):
        kk_conn_crd = KubernetesService.get_keycloak_connector(ms_kk_conn.keycloak_instance_name)
        if not kk_conn_crd:
            raise KeycloakConnectorCrdDoesNotExist(
                f"Couldn't find keycloakconnector by "
                f"instance name: {ms_kk_conn.keycloak_instance_name}"
            )

        kk_api_cred = self.__get_kk_api_secret(kk_conn_crd)
        if not kk_api_cred:
            raise NonExistSecretForSentryConnector(
                "Couldn't find keycloak credentials"
            )

        kk_service = KeycloakServiceFactory.create(
            url=kk_api_cred.url, realm=kk_api_cred.realm,
            username=kk_api_cred.username, password=kk_api_cred.password
        )
        kk_ms_cred = self.vault_service.get_kk_ms_secret(ms_kk_conn.vault_path)
        if kk_ms_cred and kk_service.is_kk_client_exist(client_id=ms_kk_conn.client_id):
            logging.info("Keycloak client already exist")
            return

        kk_ms_cred = kk_service.configure_kk(ms_kk_conn)
        self.vault_service.create_kk_ms_secret(ms_kk_conn.vault_path, kk_ms_cred)

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
