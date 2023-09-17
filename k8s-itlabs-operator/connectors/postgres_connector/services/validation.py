from typing import List, Type

from clients.vault.exceptions import IncorrectPath
from clients.vault.factories.vault_path import VaultPathFactory
from clients.vault.vaultclient import AbstractVaultClient
from connectors.postgres_connector.dto import PgConnectorMicroserviceDto
from connectors.postgres_connector.exceptions import PostgresConnectorInfrastructureError, \
    PostgresConnectorApplicationError
from connectors.postgres_connector.services.kubernetes import AbstractKubernetesService
from connectors.postgres_connector.specifications import REQUIRED_POSTGRES_SECRET_KEYS
from exceptions import InfrastructureServiceProblem
from validation.abstract_service import ConnectorValidationService
from validation.exceptions import ConnectorError


class PostgresConnectorValidationService(ConnectorValidationService):
    def __init__(self, kube_service: Type[AbstractKubernetesService], vault_client: AbstractVaultClient):
        super().__init__()

        self._kube_service = kube_service
        self._vault_client = vault_client

        self.errors: List[ConnectorError] = []

    def validate(self, postgres_connector_dto: PgConnectorMicroserviceDto) -> List[ConnectorError]:
        self.errors = []

        self._check_instance(postgres_connector_dto.pg_instance_name)
        self._check_vault_secret(postgres_connector_dto.vault_path)

        return self.errors

    def _check_instance(self, instance_name: str):
        instance_connector = self._kube_service.get_pg_connector(instance_name)
        if not instance_connector:
            self.errors.append(PostgresConnectorInfrastructureError(
                f"Postgres Custom Resource `{instance_name}` does not exist"
            ))

    def _check_vault_secret(self, secret_path: str):
        try:
            VaultPathFactory.path_from_str(secret_path)
            secret = self._vault_client.read_secret(secret_path)
        except IncorrectPath:
            self.errors.append(PostgresConnectorApplicationError(
                f"Couldn't parse Vault secret path: {secret_path} "
                f"for Postgres"
            ))
            return
        except InfrastructureServiceProblem:
            self.errors.append(PostgresConnectorInfrastructureError(
                f"Problems with reading secret `{secret_path}` from Vault "
                f"for Postgres"
            ))
            return

        # Assuming that Vault secret doesn't exist
        if secret is None:
            return

        secret_keys = set(secret.keys())
        required_keys = set(REQUIRED_POSTGRES_SECRET_KEYS)
        unset_keys = required_keys - secret_keys
        if unset_keys:
            self.errors.append(PostgresConnectorApplicationError(
                "Vault secret path for application doesn't contains next keys: "
                f"{', '.join(unset_keys)} for Postgres"
            ))
