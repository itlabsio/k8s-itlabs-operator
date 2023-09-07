import pytest

from clients.vault.tests.mocks import MockedVaultClient
from connectors.keycloak_connector.factories.dto_factory import \
    KeycloakConnectorMicroserviceDtoFactory
from connectors.keycloak_connector.services.validation import \
    KeycloakConnectorValidationService, KeycloakConnectorApplicationError
from connectors.keycloak_connector.tests.mocks import MockKubernetesService


@pytest.mark.unit
class TestKeycloakConnectorValidationService:
    @pytest.fixture
    def vault(self):
        return MockedVaultClient(secret={
            "KEYCLOAK_CLIENT_ID": "keycloak",
            "KEYCLOAK_SECRET_KEY": "00000000-0000-0000-0000-000000000000",
        })

    @pytest.fixture
    def kube(self):
        return MockKubernetesService()

    def test_annotation_contain_incorrect_vault_secret(self, kube, vault):
        annotations = {
            "keycloak.connector.itlabs.io/instance-name": "keycloak",
            "keycloak.connector.itlabs.io/vault-path": "secret/data/keycloak",
            "keycloak.connector.itlabs.io/client-id": "keycloak",
        }

        connector_dto = KeycloakConnectorMicroserviceDtoFactory.dto_from_metadata(
            annotations)
        service = KeycloakConnectorValidationService(kube, vault)
        errors = service.validate(connector_dto)

        assert KeycloakConnectorApplicationError(
            "Couldn't parse Vault secret path: secret/data/keycloak for Keycloak"
        ) in errors

    def test_vault_secret_not_contains_some_expected_keys(self, kube):
        annotations = {
            "keycloak.connector.itlabs.io/instance-name": "keycloak",
            "keycloak.connector.itlabs.io/vault-path": "vault:secret/data/keycloak",
            "keycloak.connector.itlabs.io/client-id": "keycloak",
        }

        vault = MockedVaultClient(secret={
            "KEYCLOAK_CLIENT_ID": "keycloak"
        })

        connector_dto = KeycloakConnectorMicroserviceDtoFactory.dto_from_metadata(
            annotations)
        service = KeycloakConnectorValidationService(kube, vault)
        errors = service.validate(connector_dto)

        assert KeycloakConnectorApplicationError(
            "Vault secret path for application doesn't contains next keys: "
            "KEYCLOAK_SECRET_KEY for Keycloak"
        ) in errors
