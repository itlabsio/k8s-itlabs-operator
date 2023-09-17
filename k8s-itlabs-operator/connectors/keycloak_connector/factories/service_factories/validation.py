from clients.vault.factories.vault_client import VaultClientFactory
from connectors.keycloak_connector.services.kubernetes import KubernetesService
from connectors.keycloak_connector.services.validation import \
    KeycloakConnectorValidationService


class KeycloakConnectorValidationServiceFactory:
    @staticmethod
    def create() -> KeycloakConnectorValidationService:
        return KeycloakConnectorValidationService(
            kube_service=KubernetesService,
            vault_client=VaultClientFactory.create_vault_client(),
        )
