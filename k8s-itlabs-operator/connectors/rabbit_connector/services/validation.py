from typing import List

from clients.vault.exceptions import IncorrectPath
from clients.vault.factories.vault_path import VaultPathFactory
from clients.vault.vaultclient import AbstractVaultClient
from connectors.rabbit_connector.dto import RabbitConnectorMicroserviceDto
from connectors.rabbit_connector.services.kubernetes import \
    AbstractKubernetesService
from connectors.rabbit_connector.specifications import \
    REQUIRED_RABBIT_SECRET_KEYS
from exceptions import InfrastructureServiceProblem
from utils.validation import ConnectorError, ConnectorValidationService


class RabbitConnectorError(ConnectorError):
    pass


class RabbitConnectorApplicationError(RabbitConnectorError):
    pass


class RabbitConnectorInfrastructureError(RabbitConnectorError):
    pass


class RabbitConnectorValidationService(ConnectorValidationService):
    def __init__(self, kube_service: AbstractKubernetesService, vault_client: AbstractVaultClient):
        super().__init__()

        self._kube_service = kube_service
        self._vault_client = vault_client

        self.errors: List[ConnectorError] = []

    def validate(self, rabbit_connector_dto: RabbitConnectorMicroserviceDto) -> List[ConnectorError]:
        self.errors = []

        self._check_instance(rabbit_connector_dto.rabbit_instance_name)
        self._check_username(rabbit_connector_dto.username)
        self._check_vhost(rabbit_connector_dto.vhost)
        self._check_vault_secret(rabbit_connector_dto.vault_path)

        return self.errors

    def _check_instance(self, instance_name: str):
        if not instance_name:
            self.errors.append(RabbitConnectorApplicationError(
                "RabbitMQ instance name for application "
                "is not set in annotations"
            ))
            return

        instance_connector = self._kube_service.get_rabbit_connector(instance_name)
        if not instance_connector:
            self.errors.append(RabbitConnectorInfrastructureError(
                f"RabbitMQ Custom Resource `{instance_name}` does not exist"
            ))

    def _check_username(self, username: str):
        if not username:
            self.errors.append(RabbitConnectorApplicationError(
                "RabbitMQ username for application is not set in annotations"
            ))

    def _check_vhost(self, vhost: str):
        if not vhost:
            self.errors.append(RabbitConnectorApplicationError(
                "RabbitMQ vhost for application is not set in annotations"
            ))

    def _check_vault_secret(self, secret_path: str):
        if not secret_path:
            self.errors.append(RabbitConnectorApplicationError(
                "Vault secret path for application "
                "is not set in annotations for RabbitMQ"
            ))
            return

        try:
            VaultPathFactory.path_from_str(secret_path)
            secret = self._vault_client.read_secret(secret_path)
        except IncorrectPath:
            self.errors.append(RabbitConnectorApplicationError(
                f"Couldn't parse Vault secret path: {secret_path} "
                f"for RabbitMQ"
            ))
            return
        except InfrastructureServiceProblem:
            self.errors.append(RabbitConnectorInfrastructureError(
                f"Problems with reading secret `{secret_path}` from Vault "
                f"for RabbitMQ"
            ))
            return

        # Assuming that Vault secret doesn't exist
        if secret is None:
            return

        secret_keys = set(secret.keys())
        required_keys = set(REQUIRED_RABBIT_SECRET_KEYS)
        unset_keys = required_keys - secret_keys
        if unset_keys:
            self.errors.append(RabbitConnectorApplicationError(
                "Vault secret path for application doesn't contains next keys: "
                f"{', '.join(unset_keys)} for RabbitMQ"
            ))
