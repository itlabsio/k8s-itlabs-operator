class KeycloakConnectorError(Exception):
    pass


class KeycloakConnectorCrdDoesNotExist(KeycloakConnectorError):
    pass


class NonExistSecretForKeycloakConnector(KeycloakConnectorError):
    pass
