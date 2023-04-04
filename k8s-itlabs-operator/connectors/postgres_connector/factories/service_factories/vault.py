from clients.vault.factories.vault_client import VaultClientFactory
from connectors.postgres_connector.services.vault import VaultService


class VaultServiceFactory:
    @classmethod
    def create_vault_service(cls) -> VaultService:
        vault_client = VaultClientFactory.create_vault_client()
        return VaultService(vault_client=vault_client)
