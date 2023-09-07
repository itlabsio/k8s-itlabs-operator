from typing import List

from connectors.keycloak_connector import specifications


class KeycloakConnectorError(Exception):
    pass


class KeycloakConnectorCrdDoesNotExist(KeycloakConnectorError):
    pass


class NonExistSecretForKeycloakConnector(KeycloakConnectorError):
    pass


class KeycloakConnectorMissingRequiredAnnotationError(KeycloakConnectorError):
    pass


class KeycloakConnectorAnnotationEmptyValueError(KeycloakConnectorError):
    def __init__(self, annotation_name: str):
        super().__init__()
        if annotation_name == specifications.KEYCLOAK_INSTANCE_NAME_ANNOTATION:
            required_data = "Keycloak instance name"
        elif annotation_name == specifications.KEYCLOAK_CLIENT_ID_ANNOTATION:
            required_data = "Keycloak client id"
        elif annotation_name == specifications.KEYCLOAK_VAULT_PATH_ANNOTATION:
            required_data = "Keycloak's vault secret path"
        else:
            required_data = annotation_name
        self.message = f"{required_data} for application is empty in annotations"


class KeycloakConnectorAnnotationEmptyValueErrorList(KeycloakConnectorError):
    def __init__(self, errors: List[KeycloakConnectorAnnotationEmptyValueError]):
        self.errors = errors

    @property
    def message(self) -> str:
        return ", ".join([e.message for e in self.errors])
