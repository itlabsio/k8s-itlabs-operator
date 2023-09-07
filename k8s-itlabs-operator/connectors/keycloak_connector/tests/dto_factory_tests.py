import pytest

from connectors.keycloak_connector import specifications
from connectors.keycloak_connector.exceptions import KeycloakConnectorMissingRequiredAnnotationError, \
    KeycloakConnectorAnnotationEmptyValueErrorList, KeycloakConnectorAnnotationEmptyValueError
from connectors.keycloak_connector.factories.dto_factory import KeycloakConnectorMicroserviceDtoFactory


@pytest.mark.unit
class TestKeycloakConnectorMicroserviceDtoFactory:
    def test_all_annotations_exists(self):
        annotations = {
            "keycloak.connector.itlabs.io/instance-name": "keycloak",
            "keycloak.connector.itlabs.io/vault-path": "vault:secret/data/keycloak",
            "keycloak.connector.itlabs.io/client-id": "keycloak",
        }
        connector_dto = KeycloakConnectorMicroserviceDtoFactory.dto_from_metadata(annotations)
        assert connector_dto

    @pytest.mark.parametrize("annotations", [{}, {specifications.KEYCLOAK_INSTANCE_NAME_ANNOTATION: "asd"}])
    def test_required_annotations_not_exists(self, annotations):
        with pytest.raises(KeycloakConnectorMissingRequiredAnnotationError):
            KeycloakConnectorMicroserviceDtoFactory.dto_from_metadata(annotations)

    def test_required_annotations_are_empty(self):
        annotations = {x: "" for x in specifications.KEYCLOAK_CONNECTOR_REQUIRED_ANNOTATIONS}
        with pytest.raises(KeycloakConnectorAnnotationEmptyValueErrorList) as e:
            KeycloakConnectorMicroserviceDtoFactory.dto_from_metadata(annotations)
            assert len(e.value.errors) == len(specifications.KEYCLOAK_CONNECTOR_REQUIRED_ANNOTATIONS)
            assert KeycloakConnectorAnnotationEmptyValueError(
                specifications.KEYCLOAK_CLIENT_ID_ANNOTATION) in e.value.errors
            assert KeycloakConnectorAnnotationEmptyValueError(
                specifications.KEYCLOAK_VAULT_PATH_ANNOTATION) in e.value.errors
            assert KeycloakConnectorAnnotationEmptyValueError(
                specifications.KEYCLOAK_INSTANCE_NAME_ANNOTATION) in e.value.errors

    def test_required_annotations_only_one_is_empty(self):
        annotations = {x: "1" for x in specifications.KEYCLOAK_CONNECTOR_REQUIRED_ANNOTATIONS}
        annotations[specifications.KEYCLOAK_CLIENT_ID_ANNOTATION] = ""
        with pytest.raises(KeycloakConnectorAnnotationEmptyValueErrorList) as e:
            KeycloakConnectorMicroserviceDtoFactory.dto_from_metadata(annotations)
            assert len(e.value.errors) == 1
            assert KeycloakConnectorAnnotationEmptyValueError(
                specifications.KEYCLOAK_CLIENT_ID_ANNOTATION) in e.value.errors
