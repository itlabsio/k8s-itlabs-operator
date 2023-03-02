from typing import Optional

from clients.postgres.dto import PgConnectorDbSecretDto
from connectors.postgres_connector.dto import PgConnectorInstanceSecretDto, PgConnector
from connectors.postgres_connector.services.postgres import AbstractPostgresService
from connectors.postgres_connector.services.vault import AbstractVaultService


class MockedVaultService(AbstractVaultService):
    def __init__(self, pg_instance_cred: Optional[PgConnectorInstanceSecretDto] = None,
                 ms_pg_cred: Optional[PgConnectorDbSecretDto] = None):
        self.pg_instance_cred = pg_instance_cred
        self.ms_pg_cred = ms_pg_cred
        self.get_pg_instance_credentials_call_count = 0
        self.get_pg_ms_credentials_call_count = 0
        self.create_pg_ms_credentials_call_count = 0
        self.get_vault_env_value_call_count = 0

    def get_pg_instance_secret(self, vault_path: str) -> Optional[str]:
        self.get_pg_instance_credentials_call_count += 1
        return self.pg_instance_cred

    def get_pg_ms_credentials(self, vault_path: str) -> Optional[PgConnectorDbSecretDto]:
        self.get_pg_ms_credentials_call_count += 1
        return self.ms_pg_cred

    def create_pg_ms_credentials(self, vault_path: str, pg_ms_creds: PgConnectorDbSecretDto):
        self.create_pg_ms_credentials_call_count += 1

    def get_vault_env_value(self, vault_path: str, vault_key: str) -> str:
        self.get_vault_env_value_call_count += 1
        return f'{vault_path}#{vault_key}'


class MockedPostgresService(AbstractPostgresService):
    def __init__(self):
        self.create_database_call_count = 0

    def create_database(self, db_cred: PgConnectorDbSecretDto):
        self.create_database_call_count += 1


class KubernetesServiceMocker:
    @staticmethod
    def mock_get_pg_connector(mocker, pg_connector: Optional[PgConnector] = None):
        return mocker.patch(
            'connectors.postgres_connector.services.kubernetes.KubernetesService.get_pg_connector',
            return_value=pg_connector
        )


class PostgresServiceFactoryMocker:
    @staticmethod
    def mock_create_pg_service(mocker, pg_service: Optional[AbstractPostgresService]):
        return mocker.patch(
            'connectors.postgres_connector.factories.service_factories.'
            'postgres.PostgresServiceFactory.create_pg_service',
            return_value=pg_service if pg_service else MockedPostgresService()
        )
