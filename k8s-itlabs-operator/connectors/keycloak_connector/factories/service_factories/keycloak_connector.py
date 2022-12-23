from connectors.keycloak_connector.factories.service_factories.vault import \
    VaultServiceFactory
from connectors.keycloak_connector.services.keycloak_connector import \
    KeycloakConnectorService


class KeycloakConnectorServiceFactory:
    @staticmethod
    def create() -> KeycloakConnectorService:
        vault = VaultServiceFactory.create()
        return KeycloakConnectorService(vault)
