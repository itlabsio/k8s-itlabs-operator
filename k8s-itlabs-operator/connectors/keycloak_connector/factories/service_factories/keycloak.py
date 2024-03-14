from clients.keycloak.client import KeycloakClient
from connectors.keycloak_connector.services.keycloak import KeycloakService


class KeycloakServiceFactory:
    @staticmethod
    def create(
        url: str, realm: str, username: str, password: str
    ) -> KeycloakService:
        client = KeycloakClient(url, realm, username, password)
        return KeycloakService(client)
