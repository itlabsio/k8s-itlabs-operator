from typing import Optional

from clients.vault.vaultclient import AbstractVaultClient
from connectors.keycloak_connector.dto import (
    KeycloakApiSecretDto,
    KeycloakConnector,
    KeycloakMsSecretDto,
)
from connectors.keycloak_connector.factories.dto_factory import (
    KeycloakApiSecretDtoFactory,
    KeycloakMsSecretDtoFactory,
)


class VaultService:

    def __init__(self, client: AbstractVaultClient):
        self.client = client

    def get_kk_ms_secret(self, path: str) -> Optional[KeycloakMsSecretDto]:
        data = self.client.read_secret(path)
        if data:
            return KeycloakMsSecretDtoFactory.dto_from_dict(data)

    def create_kk_ms_secret(self, path: str, kk_ms_cred: KeycloakMsSecretDto):
        secret = KeycloakMsSecretDtoFactory.dict_from_dto(kk_ms_cred)
        self.client.create_secret(path, secret)

    @staticmethod
    def get_vault_env_value(path: str, key: str) -> str:
        return f"{path}#{key}"

    def unvault_keycloak_connector(
        self, kk_connector: KeycloakConnector
    ) -> Optional[KeycloakApiSecretDto]:
        kk_connector = self.client.unvault_object(obj=kk_connector)

        if not (
            kk_connector.url
            and kk_connector.realm
            and kk_connector.username
            and kk_connector.password
        ):
            return None
        return KeycloakApiSecretDtoFactory.api_secret_dto_from_connector(
            kk_connector
        )
