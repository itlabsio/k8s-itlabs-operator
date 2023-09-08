from connectors.keycloak_connector import specifications
from connectors.keycloak_connector.crd import KeycloakConnectorCrd
from connectors.keycloak_connector.exceptions import (
    KeycloakConnectorMissingRequiredAnnotationError,
    KeycloakConnectorAnnotationEmptyValueError
)

from connectors.keycloak_connector.dto import KeycloakConnectorMicroserviceDto, \
    KeycloakConnector, KeycloakMsSecretDto, KeycloakApiSecretDto


class KeycloakConnectorMicroserviceDtoFactory:
    @classmethod
    def dto_from_metadata(cls, annotations: dict) -> KeycloakConnectorMicroserviceDto:
        required_annotations = {x: annotations[x] for x in annotations if
                                x in specifications.KEYCLOAK_CONNECTOR_REQUIRED_ANNOTATIONS}
        missed_annotation_names = [x for x in specifications.KEYCLOAK_CONNECTOR_REQUIRED_ANNOTATIONS if
                                   x not in required_annotations]
        if missed_annotation_names:
            raise KeycloakConnectorMissingRequiredAnnotationError(missed_annotation_names=missed_annotation_names)
        empty_annotation_names = [key for key in required_annotations if not annotations[key]]
        if empty_annotation_names:
            raise KeycloakConnectorAnnotationEmptyValueError(empty_annotation_names=empty_annotation_names)
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
