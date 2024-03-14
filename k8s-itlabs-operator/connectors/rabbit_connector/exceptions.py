from validation.exceptions import (
    AnnotationValidatorEmptyValueException,
    AnnotationValidatorMissedRequiredException,
    ConnectorError,
)


class RabbitConnectorError(ConnectorError):
    pass


class RabbitConnectorApplicationError(RabbitConnectorError):
    pass


class RabbitConnectorInfrastructureError(RabbitConnectorError):
    pass


class RabbitConnectorCrdDoesNotExist(RabbitConnectorError):
    pass


class UnknownVaultPathInRabbitConnector(RabbitConnectorError):
    pass


class NotMatchingUsernames(RabbitConnectorError):
    pass


class NotMatchingVhostNames(RabbitConnectorError):
    pass


class RabbitConnectorMissingRequiredAnnotationError(
    RabbitConnectorError, AnnotationValidatorMissedRequiredException
):
    pass


class RabbitConnectorAnnotationEmptyValueError(
    RabbitConnectorError, AnnotationValidatorEmptyValueException
):
    pass
