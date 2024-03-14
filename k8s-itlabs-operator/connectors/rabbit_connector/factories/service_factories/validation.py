from clients.vault.factories.vault_client import VaultClientFactory
from connectors.rabbit_connector.services.kubernetes import KubernetesService
from connectors.rabbit_connector.services.validation import (
    RabbitConnectorValidationService,
)


class RabbitConnectorValidationServiceFactory:
    @staticmethod
    def create() -> RabbitConnectorValidationService:
        return RabbitConnectorValidationService(
            kube_service=KubernetesService,
            vault_client=VaultClientFactory.create_vault_client(),
        )
