from connectors.keycloak_connector import specifications
from connectors.keycloak_connector.crd import KeycloakConnectorCrd
from connectors.keycloak_connector.exceptions import (
    KeycloakConnectorMissingRequiredAnnotationError,
    KeycloakConnectorAnnotationEmptyValueError, KeycloakConnectorAnnotationEmptyValueErrorList
)

from connectors.keycloak_connector.dto import KeycloakConnectorMicroserviceDto, \
    KeycloakConnector, KeycloakMsSecretDto, KeycloakApiSecretDto


class KeycloakConnectorMicroserviceDtoFactory:
    @classmethod
    def dto_from_metadata(cls, annotations: dict) -> KeycloakConnectorMicroserviceDto:
        errors = []
        if not all(map(lambda x: x in annotations, specifications.KEYCLOAK_CONNECTOR_REQUIRED_ANNOTATIONS)):
            raise KeycloakConnectorMissingRequiredAnnotationError()
        if not annotations.get(specifications.KEYCLOAK_INSTANCE_NAME_ANNOTATION):
            errors.append(KeycloakConnectorAnnotationEmptyValueError(specifications.KEYCLOAK_INSTANCE_NAME_ANNOTATION))
        if not annotations.get(specifications.KEYCLOAK_VAULT_PATH_ANNOTATION):
            errors.append(KeycloakConnectorAnnotationEmptyValueError(specifications.KEYCLOAK_VAULT_PATH_ANNOTATION))
        if not annotations.get(specifications.KEYCLOAK_CLIENT_ID_ANNOTATION):
            errors.append(KeycloakConnectorAnnotationEmptyValueError(specifications.KEYCLOAK_CLIENT_ID_ANNOTATION))
        if errors:
            raise KeycloakConnectorAnnotationEmptyValueErrorList(errors=errors)
        return KeycloakConnectorMicroserviceDto(
            keycloak_instance_name=annotations.get(specifications.KEYCLOAK_INSTANCE_NAME_ANNOTATION),
            vault_path=annotations.get(specifications.KEYCLOAK_VAULT_PATH_ANNOTATION),
            client_id=annotations.get(specifications.KEYCLOAK_CLIENT_ID_ANNOTATION),
        )


class KeycloakConnectorFactory:
    @staticmethod
    def dto_from_kk_connector_crd(kk_connector_crd: KeycloakConnectorCrd) -> KeycloakConnector:
        return KeycloakConnector(
            url=kk_connector_crd.spec.url,
            realm=kk_connector_crd.spec.realm,
            username=kk_connector_crd.spec.username,
            password=kk_connector_crd.spec.password,
        )


class KeycloakMsSecretDtoFactory:
    @staticmethod
    def dto_from_dict(data: dict) -> KeycloakMsSecretDto:
        return KeycloakMsSecretDto(
            client_id=data.get(specifications.KEYCLOAK_CLIENT_ID_KEY),
            secret=data.get(specifications.KEYCLOAK_SECRET_KEY),
        )

    @staticmethod
    def dict_from_dto(dto: KeycloakMsSecretDto) -> dict:
        return {
            specifications.KEYCLOAK_CLIENT_ID_KEY: dto.client_id,
            specifications.KEYCLOAK_SECRET_KEY: dto.secret,
        }


class KeycloakApiSecretDtoFactory:
    @classmethod
    def api_secret_dto_from_connector(cls, kk_connector: KeycloakConnector) -> KeycloakApiSecretDto:
        return KeycloakApiSecretDto(
            url=kk_connector.url,
            realm=kk_connector.realm,
            username=kk_connector.username,
            password=kk_connector.password,
        )
