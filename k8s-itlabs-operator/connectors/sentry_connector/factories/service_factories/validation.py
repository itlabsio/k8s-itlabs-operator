from clients.vault.factories.vault_client import VaultClientFactory
from connectors.sentry_connector.services.kubernetes import KubernetesService
from connectors.sentry_connector.services.validation import (
    SentryConnectorValidationService,
)


class SentryConnectorValidationServiceFactory:
    @staticmethod
    def create() -> SentryConnectorValidationService:
        return SentryConnectorValidationService(
            kube_service=KubernetesService,
            vault_client=VaultClientFactory.create_vault_client(),
        )
