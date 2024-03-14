from connectors.sentry_connector.factories.service_factories.vault import (
    VaultServiceFactory,
)
from connectors.sentry_connector.services.sentry_connector import (
    SentryConnectorService,
)


class SentryConnectorServiceFactory:
    @staticmethod
    def create_sentry_connector_service() -> SentryConnectorService:
        return SentryConnectorService(
            vault_service=VaultServiceFactory.create_vault_service()
        )
