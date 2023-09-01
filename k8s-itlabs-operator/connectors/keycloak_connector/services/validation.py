from typing import List

from clients.vault.exceptions import IncorrectPath
from clients.vault.factories.vault_path import VaultPathFactory
from clients.vault.vaultclient import AbstractVaultClient
from connectors.keycloak_connector.dto import KeycloakConnectorMicroserviceDto
from connectors.keycloak_connector.services.kubernetes import \
    AbstractKubernetesService
from connectors.keycloak_connector.specifications import \
    REQUIRED_KEYCLOAK_SECRET_KEYS
from exceptions import InfrastructureServiceProblem
from utils.validation import ConnectorValidationService, ConnectorError


class KeycloakConnectorError(ConnectorError):
    pass


class KeycloakConnectorApplicationError(KeycloakConnectorError):
    pass


class KeycloakConnectorInfrastructureError(KeycloakConnectorError):
    pass


class KeycloakConnectorValidationService(ConnectorValidationService):
    def __init__(self, kube_service: AbstractKubernetesService, vault_client: AbstractVaultClient):
        super().__init__()

        self._kube_service = kube_service
        self._vault_client = vault_client

        self.errors: List[ConnectorError] = []

    def validate(self, keycloak_connector_dto: KeycloakConnectorMicroserviceDto) -> List[ConnectorError] | None:
        self.errors = []

        self._check_instance(keycloak_connector_dto.keycloak_instance_name)
        self._check_client(keycloak_connector_dto.client_id)
        self._check_vault_secret(keycloak_connector_dto.vault_path)

        return self.errors

    def _check_instance(self, instance_name: str):
        if not instance_name:
            self.errors.append(KeycloakConnectorApplicationError(
                "Keycloak instance name for application "
                "is not set in annotations"
            ))
            return

        instance_connector = self._kube_service.get_keycloak_connector(instance_name)
        if not instance_connector:
            self.errors.append(KeycloakConnectorInfrastructureError(
                f"Keycloak Custom Resource `{instance_name}` does not exist"
            ))

    def _check_client(self, client_id: str):
        if not client_id:
            self.errors.append(KeycloakConnectorApplicationError(
                "Keycloak client id for application is not set in annotations"
            ))

    def _check_vault_secret(self, secret_path: str):
        if not secret_path:
            self.errors.append(KeycloakConnectorApplicationError(
                "Vault secret path for application "
                "is not set in annotations for Keycloak"
            ))
            return

        try:
            VaultPathFactory.path_from_str(secret_path)
            secret = self._vault_client.read_secret(secret_path)
        except IncorrectPath:
            self.errors.append(KeycloakConnectorApplicationError(
                f"Couldn't parse Vault secret path: {secret_path} "
                f"for Keycloak"
            ))
            return
        except InfrastructureServiceProblem:
            self.errors.append(KeycloakConnectorInfrastructureError(
                f"Problems with reading secret `{secret_path}` from Vault "
                f"for Keycloak"
            ))
            return

        # Assuming that Vault secret doesn't exist
        if secret is None:
            return

        secret_keys = set(secret.keys())
        required_keys = set(REQUIRED_KEYCLOAK_SECRET_KEYS)
        unset_keys = required_keys - secret_keys
        if unset_keys:
            self.errors.append(KeycloakConnectorApplicationError(
                "Vault secret path for application doesn't contains next keys: "
                f"{', '.join(unset_keys)} for Keycloak"
            ))
