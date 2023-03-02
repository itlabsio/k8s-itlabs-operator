from abc import ABCMeta, abstractmethod
from typing import Optional

from clients.vault.vaultclient import AbstractVaultClient
from connectors.rabbit_connector.dto import RabbitApiSecretDto, RabbitMsSecretDto
from connectors.rabbit_connector.factories.dto_factory import RabbitApiSecretDtoFactory, RabbitMsSecretDtoFactory


class AbstractVaultService:
    __metaclass__ = ABCMeta

    @abstractmethod
    def get_rabbit_instance_secret(self, vault_path: str) -> Optional[str]:
        raise NotImplementedError

    @abstractmethod
    def get_rabbit_ms_credentials(self, vault_path: str) -> RabbitMsSecretDto:
        raise NotImplementedError

    @abstractmethod
    def create_ms_rabbit_credentials(self, vault_path: str, rabbit_ms_creds: RabbitMsSecretDto):
        raise NotImplementedError

    @abstractmethod
    def get_vault_env_value(self, vault_path: str, vault_key: str) -> str:
        raise NotImplementedError


class VaultService(AbstractVaultService):
    def __init__(self, vault_client: AbstractVaultClient):
        self.vault_client = vault_client

    def get_rabbit_instance_secret(self, vault_path: str) -> Optional[str]:
        return self.vault_client.read_secret_key(vault_path)

    def get_rabbit_api_credentials(self, vault_path: str) -> RabbitApiSecretDto:
        vault_data = self.vault_client.read_secret(vault_path)
        return RabbitApiSecretDtoFactory.dto_from_dict(vault_data)

    def get_rabbit_ms_credentials(self, vault_path: str) -> RabbitMsSecretDto:
        vault_data = self.vault_client.read_secret(vault_path)
        return RabbitMsSecretDtoFactory.dto_from_dict(vault_data) if vault_data else None

    def create_ms_rabbit_credentials(self, vault_path: str, rabbit_ms_creds: RabbitMsSecretDto):
        vault_data = RabbitMsSecretDtoFactory.dict_from_dto(rabbit_ms_creds)
        self.vault_client.create_secret(vault_path, vault_data)

    def get_vault_env_value(self, vault_path: str, vault_key: str) -> str:
        return f"{vault_path}#{vault_key}"
