class SentryConnectorError(Exception):
    ...


class SentryConnectorCrdDoesNotExist(SentryConnectorError):
    ...


class NonExistSecretForSentryConnector(SentryConnectorError):
    ...


class EnvironmentValueError(ValueError):
    ...
