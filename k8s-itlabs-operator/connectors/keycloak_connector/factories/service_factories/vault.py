from clients.vault.factories.vault_client import VaultClientFactory
from connectors.keycloak_connector.services.vault import VaultService


class VaultServiceFactory:
    @staticmethod
    def create() -> VaultService:
        client = VaultClientFactory.create_vault_client()
        return VaultService(client)
