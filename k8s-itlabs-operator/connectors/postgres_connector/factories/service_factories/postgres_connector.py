from connectors.postgres_connector.factories.service_factories.vault import (
    VaultServiceFactory,
)
from connectors.postgres_connector.services.postgres_connector import (
    PostgresConnectorService,
)


class PostgresConnectorServiceFactory:
    @classmethod
    def create_postgres_connector_service(cls) -> PostgresConnectorService:
        return PostgresConnectorService(
            vault_service=VaultServiceFactory.create_vault_service()
        )
