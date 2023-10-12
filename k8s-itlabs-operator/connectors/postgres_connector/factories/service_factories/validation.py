from clients.vault.factories.vault_client import VaultClientFactory
from connectors.postgres_connector.services.kubernetes import KubernetesService
from connectors.postgres_connector.services.validation import PostgresConnectorValidationService


class PostgresConnectorValidationServiceFactory:
    @staticmethod
    def create() -> PostgresConnectorValidationService:
        return PostgresConnectorValidationService(
            vault_client=VaultClientFactory.create_vault_client(),
            kube_service=KubernetesService(),
        )
