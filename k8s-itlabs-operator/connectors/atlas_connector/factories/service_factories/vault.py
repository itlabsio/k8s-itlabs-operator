from clients.vault.factories.vault_client import VaultClientFactory
from connectors.atlas_connector.services.vault import (
    AbstractVaultService,
    VaultService,
)


class VaultServiceFactory:
    @classmethod
    def create_vault_service(cls) -> AbstractVaultService:
        vault_client = VaultClientFactory.create_vault_client()
        return VaultService(vault_client=vault_client)
