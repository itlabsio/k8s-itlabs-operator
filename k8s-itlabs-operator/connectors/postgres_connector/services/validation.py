import dataclasses
from typing import List

from clients.vault.exceptions import IncorrectPath
from clients.vault.factories.vault_path import VaultPathFactory
from clients.vault.vaultclient import AbstractVaultClient
from connectors.postgres_connector.dto import PgConnectorMicroserviceDto
from connectors.postgres_connector.exceptions import (
    PostgresConnectorApplicationError,
    PostgresConnectorInfrastructureError,
)
from connectors.postgres_connector.factories.service_factories.postgres import (
    PostgresServiceFactory,
)
from connectors.postgres_connector.services.kubernetes import (
    AbstractKubernetesService,
)
from connectors.postgres_connector.services.vault import VaultService
from connectors.postgres_connector.specifications import (
    REQUIRED_POSTGRES_SECRET_KEYS,
)
from exceptions import InfrastructureServiceProblem
from validation.abstract_service import ConnectorValidationService
from validation.exceptions import ConnectorError


class PostgresConnectorValidationService(ConnectorValidationService):
    def __init__(
        self,
        vault_client: AbstractVaultClient,
        kube_service: AbstractKubernetesService,
    ):
        super().__init__()

        self._vault_client = vault_client
        self._kube_service = kube_service

        self.errors: List[ConnectorError] = []

    def validate(
        self, postgres_connector_dto: PgConnectorMicroserviceDto
    ) -> List[ConnectorError]:
        self.errors = []

        self._check_instance(postgres_connector_dto.pg_instance_name)
        self._check_vault_secret(postgres_connector_dto.vault_path)

        if not self.errors:
            self._check_readonly_user(
                postgres_connector_dto.pg_instance_name,
                postgres_connector_dto.db_name,
                postgres_connector_dto.grant_access_for_readonly_user,
            )

        return self.errors

    def _check_instance(self, instance_name: str):
        instance_connector = self._kube_service.get_pg_connector(instance_name)
        if not instance_connector:
            self.errors.append(
                PostgresConnectorInfrastructureError(
                    f"Postgres Custom Resource `{instance_name}` does not exist"
                )
            )

    def _check_vault_secret(self, secret_path: str):
        try:
            VaultPathFactory.path_from_str(secret_path)
            secret = self._vault_client.read_secret(secret_path)
        except IncorrectPath:
            self.errors.append(
                PostgresConnectorApplicationError(
                    f"Couldn't parse Vault secret path: {secret_path} "
                    f"for Postgres"
                )
            )
            return
        except InfrastructureServiceProblem:
            self.errors.append(
                PostgresConnectorInfrastructureError(
                    f"Problems with reading secret `{secret_path}` from Vault "
                    f"for Postgres"
                )
            )
            return

        # Assuming that Vault secret doesn't exist
        if secret is None:
            return

        secret_keys = set(secret.keys())
        required_keys = set(REQUIRED_POSTGRES_SECRET_KEYS)
        unset_keys = required_keys - secret_keys
        if unset_keys:
            self.errors.append(
                PostgresConnectorApplicationError(
                    "Vault secret path for application doesn't contains next keys: "
                    f"{', '.join(unset_keys)} for Postgres"
                )
            )

    def _check_readonly_user(
        self, instance_name: str, database: str, is_grant_access: bool
    ):
        if not is_grant_access:
            return

        instance_connector = self._kube_service.get_pg_connector(instance_name)
        if not instance_connector.readonly_username:
            self.errors.append(
                PostgresConnectorInfrastructureError(
                    f"Username for readonly access to the database is not set in "
                    f"Custom Resource `{instance_name}` for Postgres"
                )
            )
            return

        vault_service = VaultService(self._vault_client)

        instance_credentials = vault_service.unvault_pg_connector(
            instance_connector
        )
        readonly_username = instance_credentials.readonly_username

        # Set connection to application database for check grant access
        access_credentials = dataclasses.replace(
            instance_credentials, db_name=database
        )
        postgres_service = PostgresServiceFactory.create_pg_service(
            access_credentials
        )
        if not postgres_service.is_user_exist(readonly_username):
            self.errors.append(
                PostgresConnectorInfrastructureError(
                    f"Username for readonly access to the database does not exist "
                    f"in `{instance_name}`"
                )
            )
            return

        if not postgres_service.is_user_grantee(database, readonly_username):
            self.errors.append(
                PostgresConnectorInfrastructureError(
                    "Access for readonly is not granted by unknown reasons"
                )
            )
