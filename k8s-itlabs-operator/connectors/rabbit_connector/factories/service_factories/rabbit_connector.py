from connectors.rabbit_connector.factories.service_factories.vault import (
    VaultServiceFactory,
)
from connectors.rabbit_connector.services.rabbit_connector import (
    RabbitConnectorService,
)


class RabbitConnectorServiceFactory:
    @classmethod
    def create_rabbit_connector_service(cls) -> RabbitConnectorService:
        return RabbitConnectorService(
            vault_service=VaultServiceFactory.create_vault_service()
        )
