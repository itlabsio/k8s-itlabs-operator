from typing import Optional

from connectors.keycloak_connector.dto import KeycloakConnector
from connectors.keycloak_connector.services.kubernetes import (
    AbstractKubernetesService,
)


class MockKubernetesService(AbstractKubernetesService):
    @classmethod
    def get_keycloak_connector(cls, name: str) -> Optional[KeycloakConnector]:
        return KeycloakConnector(
            url="https://keycloak.local",
            realm="master",
            username="vault:secret/data/infrastructure/keycloak#USERNAME",
            password="vault:secret/data/infrastructure/keycloak#PASSWORD",
        )
