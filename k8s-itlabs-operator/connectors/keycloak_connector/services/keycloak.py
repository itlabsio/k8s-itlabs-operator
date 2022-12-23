from clients.keycloak.client import AbstractKeycloakClient
from clients.keycloak.dto import ClientDto
from connectors.keycloak_connector.dto import KeycloakConnectorMicroserviceDto, \
    KeycloakMsSecretDto


class KeycloakService:
    def __init__(self, client: AbstractKeycloakClient):
        self._client = client

    def is_kk_client_exist(self, client_id: str) -> bool:
        client = self._client.get_client(client_id=client_id)
        return client is not None

    def configure_kk(self, config: KeycloakConnectorMicroserviceDto) -> KeycloakMsSecretDto:
        data = ClientDto(client_id=config.client_id, name=config.client_id)
        self._client.create_client(data)

        created_client = self._client.get_client(config.client_id)
        created_secret = self._client.generate_secret(created_client.id)

        return KeycloakMsSecretDto(
            client_id=created_client.client_id,
            secret=created_secret,
        )
