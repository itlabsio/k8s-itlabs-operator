from abc import ABCMeta, abstractmethod
from typing import Optional

from clients.vault.vaultclient import AbstractVaultClient
from connectors.sentry_connector.dto import SentryMsSecretDto, SentryConnector, SentryApiSecretDto
from connectors.sentry_connector.factories.dto_factory import SentryMsSecretDtoFactory, SentryApiSecretDtoFactory


class AbstractVaultService:
    __metaclass__ = ABCMeta

    @abstractmethod
    def get_sentry_ms_credentials(self, vault_path: str) -> SentryMsSecretDto:
        raise NotImplementedError

    @abstractmethod
    def create_ms_sentry_credentials(self, vault_path: str, sentry_ms_cred: SentryMsSecretDto):
        raise NotImplementedError

    @abstractmethod
    def get_vault_env_value(self, vault_path: str, vault_key: str) -> str:
        raise NotImplementedError

    @abstractmethod
    def unvault_sentry_connector(self, sentry_connector: SentryConnector) -> Optional[SentryApiSecretDto]:
        raise NotImplementedError


class VaultService(AbstractVaultService):
    def __init__(self, vault_client: AbstractVaultClient):
        self.vault_client = vault_client

    def get_sentry_ms_credentials(self, vault_path: str) -> Optional[SentryMsSecretDto]:
        vault_data = self.vault_client.read_secret(vault_path)
        if vault_data:
            return SentryMsSecretDtoFactory.dto_from_dict(vault_data)

    def create_ms_sentry_credentials(self, vault_path: str, sentry_ms_cred: SentryMsSecretDto):
        vault_data = SentryMsSecretDtoFactory.dict_from_dto(sentry_ms_cred)
        self.vault_client.create_secret(vault_path, vault_data)

    def get_vault_env_value(self, vault_path: str, vault_key: str) -> str:
        return f"{vault_path}#{vault_key}"

    def unvault_sentry_connector(self, sentry_connector: SentryConnector) -> Optional[SentryApiSecretDto]:
        sentry_connector = self.vault_client.unvault_object(sentry_connector)
        if not (
                sentry_connector.url and
                sentry_connector.token and
                sentry_connector.organization
        ):
            return None
        return SentryApiSecretDtoFactory.api_secret_dto_from_connector(sentry_connector)
