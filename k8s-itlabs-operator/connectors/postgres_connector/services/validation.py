from typing import Dict, List

from clients.vault.exceptions import IncorrectPath
from clients.vault.factories.vault_path import VaultPathFactory
from clients.vault.vaultclient import AbstractVaultClient
from connectors.postgres_connector.services.kubernetes import AbstractKubernetesService
from connectors.postgres_connector.specifications import \
    PG_INSTANCE_NAME_ANNOTATION, DB_NAME_ANNOTATION, USER_NAME_ANNOTATION, \
    VAULTPATH_NAME_ANNOTATION, APP_NAME_LABEL, DATABASE_HOST_KEY, \
    DATABASE_PORT_KEY, DATABASE_NAME_KEY, DATABASE_USER_KEY, \
    DATABASE_PASSWORD_KEY
from exceptions import InfrastructureServiceProblem
from utils.validation import ConnectorValidationService, ConnectorError


class PostgresConnectorError(ConnectorError):
    pass


class PostgresConnectorApplicationError(PostgresConnectorError):
    pass


class PostgresConnectorInfrastructureError(PostgresConnectorError):
    pass


class PostgresConnectorValidationService(ConnectorValidationService):
    def __init__(self, kube: AbstractKubernetesService, vault: AbstractVaultClient):
        super().__init__()

        self._kube = kube
        self._vault = vault

        self.errors: List[ConnectorError] = []

    def validate(self, annotations: Dict[str, str], labels: Dict[str, str]) -> List[ConnectorError]:
        self.errors = []

        instance_name = annotations.get(PG_INSTANCE_NAME_ANNOTATION, "")
        self._check_instance(instance_name)

        default = labels.get(APP_NAME_LABEL, "")

        database = annotations.get(DB_NAME_ANNOTATION, default)
        self._check_database(database)

        username = annotations.get(USER_NAME_ANNOTATION, default)
        self._check_username(username)

        secret_path = annotations.get(VAULTPATH_NAME_ANNOTATION, "")
        self._check_vault_secret(secret_path)

        return self.errors

    def _check_instance(self, instance_name: str):
        if not instance_name:
            self.errors.append(PostgresConnectorApplicationError(
                "Instance name for application is not set in annotations"
            ))
            return

        instance_connector = self._kube.get_pg_connector(instance_name)
        if not instance_connector:
            self.errors.append(PostgresConnectorInfrastructureError(
                f"Postgres Custom Resource `{instance_name}` does not exist"
            ))

        # in additional we can check vault secret stored in CR and
        # also that this secret key contains required keys
        # (but it's not a user problem)

    def _check_database(self, database: str):
        if not database:
            self.errors.append(PostgresConnectorApplicationError(
                "Database name for application is not set in annotations"
            ))

    def _check_username(self, username: str):
        if not username:
            self.errors.append(PostgresConnectorApplicationError(
                "Username for application is not set in annotations"
            ))

    def _check_vault_secret(self, secret_path: str):
        if not secret_path:
            self.errors.append(PostgresConnectorApplicationError(
                "Vault secret path for application is not set in annotations"
            ))
            return

        try:
            VaultPathFactory.path_from_str(secret_path)
            secret = self._vault.read_secret(secret_path)
        except IncorrectPath:
            self.errors.append(PostgresConnectorApplicationError(
                f"Couldn't parse Vault secret path: {secret_path}"
            ))
            return
        except InfrastructureServiceProblem:
            self.errors.append(PostgresConnectorInfrastructureError(
                f"Problems with reading secret `{secret_path}` from Vault"
            ))
            return

        # Assuming that Vault secret doesn't exist
        if secret is None:
            return

        secret_keys = set(secret.keys())
        required_keys = {
            DATABASE_HOST_KEY,
            DATABASE_PORT_KEY,
            DATABASE_NAME_KEY,
            DATABASE_USER_KEY,
            DATABASE_PASSWORD_KEY,
        }
        unset_keys = required_keys - secret_keys
        if unset_keys:
            self.errors.append(PostgresConnectorApplicationError(
                "Vault secret path for application doesn't contains next keys: "
                f"{', '.join(unset_keys)}"
            ))


