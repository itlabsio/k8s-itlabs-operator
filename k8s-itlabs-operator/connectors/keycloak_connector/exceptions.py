class KeycloakConnectorError(Exception):
    pass


class KeycloakConnectorCrdDoesNotExist(KeycloakConnectorError):
    pass


class NonExistSecretForSentryConnector(KeycloakConnectorError):
    pass
