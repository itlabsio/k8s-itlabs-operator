class SentryConnectorError(Exception):
    ...


class SentryConnectorCrdDoesNotExist(SentryConnectorError):
    ...


class NonExistSecretForSentryConnector(SentryConnectorError):
    ...


class NonExistMicroserviceSecretForSentryConnector(SentryConnectorError):
    ...


class EnvironmentValueError(ValueError):
    ...
