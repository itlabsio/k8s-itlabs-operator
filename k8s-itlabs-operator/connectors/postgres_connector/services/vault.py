from abc import ABCMeta, abstractmethod
from typing import Optional

from clients.postgres.dto import PgConnectorDbSecretDto
from clients.vault.vaultclient import AbstractVaultClient
from connectors.postgres_connector.dto import (
    PgConnector,
    PgConnectorInstanceSecretDto,
)
from connectors.postgres_connector.factories.dto_factory import (
    PgConnectorDbSecretDtoFactory,
    PgConnectorInstanceSecretDtoFactory,
)


class AbstractVaultService:
    __metaclass__ = ABCMeta

    @abstractmethod
    def get_pg_ms_credentials(
        self, vault_path: str
    ) -> Optional[PgConnectorDbSecretDto]:
        raise NotImplementedError

    @abstractmethod
    def create_pg_ms_credentials(
        self, vault_path: str, pg_ms_cred: PgConnectorDbSecretDto
    ):
        raise NotImplementedError

    @abstractmethod
    def get_vault_env_value(self, vault_path: str, vault_key: str) -> str:
        raise NotImplementedError

    @abstractmethod
    def unvault_pg_connector(
        self, pg_connector: PgConnector
    ) -> Optional[PgConnectorInstanceSecretDto]:
        raise NotImplementedError


class VaultService(AbstractVaultService):

    def __init__(self, vault_client: AbstractVaultClient):
        self.vault_client = vault_client

    def get_pg_ms_credentials(
        self, vault_path: str
    ) -> Optional[PgConnectorDbSecretDto]:
        vault_data = self.vault_client.read_secret(vault_path)
        return (
            PgConnectorDbSecretDtoFactory.dto_from_dict(vault_data)
            if vault_data
            else None
        )

    def create_pg_ms_credentials(
        self, vault_path: str, pg_ms_cred: PgConnectorDbSecretDto
    ):
        vault_data = PgConnectorDbSecretDtoFactory.vault_data_from_dto(
            pg_con_db_cred=pg_ms_cred
        )
        self.vault_client.create_secret(path=vault_path, data=vault_data)

    def get_vault_env_value(self, vault_path: str, vault_key: str) -> str:
        return f"{vault_path}#{vault_key}"

    def unvault_pg_connector(
        self, pg_connector: PgConnector
    ) -> Optional[PgConnectorInstanceSecretDto]:
        pg_connector = self.vault_client.unvault_object(obj=pg_connector)
        if not (
            pg_connector.host
            and pg_connector.port
            and pg_connector.database
            and pg_connector.username
            and pg_connector.password
        ):
            return None
        return (
            PgConnectorInstanceSecretDtoFactory.api_secret_dto_from_connector(
                pg_connector
            )
        )
