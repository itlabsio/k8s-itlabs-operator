from clients.vault.factory import VaultClientFactory
from connectors.sentry_connector.services.vault import VaultService


class VaultServiceFactory:
    @staticmethod
    def create_vault_service() -> VaultService:
        vault_client = VaultClientFactory.create_vault_client()
        return VaultService(vault_client=vault_client)
