from connectors.atlas_connector.services.vault import VaultService, AbstractVaultService
from clients.vault.factory import VaultClientFactory


class VaultServiceFactory:
    @classmethod
    def create_vault_service(cls) -> AbstractVaultService:
        vault_client = VaultClientFactory.create_vault_client()
        return VaultService(vault_client=vault_client)
