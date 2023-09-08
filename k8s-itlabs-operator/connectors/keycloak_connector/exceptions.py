from typing import List


class KeycloakConnectorError(Exception):
    pass


class KeycloakConnectorCrdDoesNotExist(KeycloakConnectorError):
    pass


class NonExistSecretForKeycloakConnector(KeycloakConnectorError):
    pass


class KeycloakConnectorMissingRequiredAnnotationError(KeycloakConnectorError):
    def __init__(self, missed_annotation_names: List[str]):
        super().__init__()
        self.missed_annotation_names = missed_annotation_names
        annotations = ', '.join(missed_annotation_names)
        self.message = f"Missed required annotations: {annotations}"


class KeycloakConnectorAnnotationEmptyValueError(KeycloakConnectorError):
    def __init__(self, empty_annotation_names: List[str]):
        super().__init__()
        self.empty_annotation_names = empty_annotation_names
        annotations = ', '.join(empty_annotation_names)
        self.message = f"Unaccessable empty value for annotations: {annotations}"
