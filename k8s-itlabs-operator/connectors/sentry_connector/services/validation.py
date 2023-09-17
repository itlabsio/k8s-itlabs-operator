from typing import List

from clients.vault.exceptions import IncorrectPath
from clients.vault.factories.vault_path import VaultPathFactory
from clients.vault.vaultclient import AbstractVaultClient
from connectors.sentry_connector.dto import SentryConnectorMicroserviceDto
from connectors.sentry_connector.exceptions import SentryConnectorApplicationError, SentryConnectorInfrastructureError
from connectors.sentry_connector.services.kubernetes import \
    AbstractKubernetesService
from connectors.sentry_connector.specifications import \
    REQUIRED_SENTRY_SECRET_KEYS
from exceptions import InfrastructureServiceProblem
from validation.abstract_service import ConnectorValidationService
from validation.exceptions import ConnectorError


class SentryConnectorValidationService(ConnectorValidationService):
    def __init__(self, kube_service: AbstractKubernetesService, vault_client: AbstractVaultClient):
        super().__init__()

        self._kube_service = kube_service
        self._vault_client = vault_client

        self.errors: List[ConnectorError] = []

    def validate(self, sentry_connector_dto: SentryConnectorMicroserviceDto) -> List[ConnectorError]:
        self.errors = []

        self._check_instance(sentry_connector_dto.sentry_instance_name)
        self._check_team(sentry_connector_dto.team)
        self._check_project(sentry_connector_dto.project)
        self._check_vault_secret(sentry_connector_dto.vault_path)

        return self.errors

    def _check_instance(self, instance_name: str):
        if not instance_name:
            self.errors.append(SentryConnectorApplicationError(
                "Sentry instance name for application is not set in annotations"
            ))
            return

        instance_connector = self._kube_service.get_sentry_connector(instance_name)
        if not instance_connector:
            self.errors.append(SentryConnectorInfrastructureError(
                f"Sentry Custom Resource `{instance_name}` does not exist"
            ))

    def _check_team(self, team: str):
        if not team:
            self.errors.append(SentryConnectorApplicationError(
                "Sentry team for application is not set in annotations"
            ))

    def _check_project(self, project: str):
        if not project:
            self.errors.append(SentryConnectorApplicationError(
                "Sentry project for application is not set in annotations"
            ))

    def _check_vault_secret(self, secret_path: str):
        if not secret_path:
            self.errors.append(SentryConnectorApplicationError(
                "Vault secret path for application is not set in annotations "
                "for Sentry"
            ))
            return

        try:
            VaultPathFactory.path_from_str(secret_path)
            secret = self._vault_client.read_secret(secret_path)
        except IncorrectPath:
            self.errors.append(SentryConnectorApplicationError(
                f"Couldn't parse Vault secret path: {secret_path} for Sentry"
            ))
            return
        except InfrastructureServiceProblem:
            self.errors.append(SentryConnectorInfrastructureError(
                f"Problems with reading secret `{secret_path}` from Vault "
                f"for Sentry"
            ))
            return

        # Assuming that Vault secret doesn't exist
        if secret is None:
            return

        secret_keys = set(secret.keys())
        required_keys = set(REQUIRED_SENTRY_SECRET_KEYS)
        unset_keys = required_keys - secret_keys
        if unset_keys:
            self.errors.append(SentryConnectorApplicationError(
                "Vault secret path for application doesn't contains next keys: "
                f"{', '.join(unset_keys)} for Sentry"
            ))
