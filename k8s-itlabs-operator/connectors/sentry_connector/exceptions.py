from validation.exceptions import ConnectorError, AnnotationValidatorEmptyValueException, \
    AnnotationValidatorMissedRequiredException


class SentryConnectorError(ConnectorError):
    pass


class SentryConnectorApplicationError(SentryConnectorError):
    pass


class SentryConnectorInfrastructureError(SentryConnectorError):
    pass


class SentryConnectorCrdDoesNotExist(SentryConnectorError):
    pass


class NonExistSecretForSentryConnector(SentryConnectorError):
    pass


class SentryConnectorMissingRequiredAnnotationError(SentryConnectorError, AnnotationValidatorMissedRequiredException):
    pass


class SentryConnectorAnnotationEmptyValueError(SentryConnectorError, AnnotationValidatorEmptyValueException):
    pass
