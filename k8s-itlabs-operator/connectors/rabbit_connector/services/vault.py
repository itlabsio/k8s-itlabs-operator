from abc import ABCMeta, abstractmethod
from typing import Optional

from clients.vault.vaultclient import AbstractVaultClient
from connectors.rabbit_connector.dto import RabbitMsSecretDto, RabbitConnector, RabbitApiSecretDto
from connectors.rabbit_connector.factories.dto_factory import RabbitMsSecretDtoFactory, RabbitApiSecretDtoFactory


class AbstractVaultService:
    __metaclass__ = ABCMeta

    @abstractmethod
    def get_rabbit_ms_credentials(self, vault_path: str) -> RabbitMsSecretDto:
        raise NotImplementedError

    @abstractmethod
    def create_ms_rabbit_credentials(self, vault_path: str, rabbit_ms_cred: RabbitMsSecretDto):
        raise NotImplementedError

    @abstractmethod
    def get_vault_env_value(self, vault_path: str, vault_key: str) -> str:
        raise NotImplementedError

    def unvault_rabbit_connector(self, rabbit_connector: RabbitConnector) -> Optional[RabbitApiSecretDto]:
        raise NotImplementedError


class VaultService(AbstractVaultService):
    def __init__(self, vault_client: AbstractVaultClient):
        self.vault_client = vault_client

    def get_rabbit_ms_credentials(self, vault_path: str) -> RabbitMsSecretDto:
        vault_data = self.vault_client.read_secret(vault_path)
        return RabbitMsSecretDtoFactory.dto_from_dict(vault_data) if vault_data else None

    def create_ms_rabbit_credentials(self, vault_path: str, rabbit_ms_cred: RabbitMsSecretDto):
        vault_data = RabbitMsSecretDtoFactory.dict_from_dto(rabbit_ms_cred)
        self.vault_client.create_secret(vault_path, vault_data)

    def get_vault_env_value(self, vault_path: str, vault_key: str) -> str:
        return f"{vault_path}#{vault_key}"

    def unvault_rabbit_connector(self, rabbit_connector: RabbitConnector) -> Optional[RabbitApiSecretDto]:
        rabbit_connector = self.vault_client.unvault_object(obj=rabbit_connector)
        if not (
                rabbit_connector.username or
                rabbit_connector.password or
                rabbit_connector.url or
                rabbit_connector.broker_port or
                rabbit_connector.broker_host
        ):
            return None
        return RabbitApiSecretDtoFactory.api_secret_dto_from_connector(rabbit_connector=rabbit_connector)
