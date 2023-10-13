from validation.exceptions import AnnotationValidatorMissedRequiredException, AnnotationValidatorEmptyValueException, \
    ConnectorError


class PostgresConnectorError(ConnectorError):
    pass


class PostgresConnectorApplicationError(PostgresConnectorError):
    pass


class PostgresConnectorInfrastructureError(PostgresConnectorError):
    pass


class PgConnectorCrdDoesNotExist(PostgresConnectorError):
    pass


class PgConnectorReadonlyUsernameIsNotSet(PostgresConnectorError):
    pass


class PgConnectorReadonlyUsernameDoesNotExist(PostgresConnectorError):
    pass


class UnknownVaultPathInPgConnector(PostgresConnectorError):
    pass


class NotMatchingUsernames(PostgresConnectorError):
    pass


class NotMatchingDbNames(PostgresConnectorError):
    pass


class PgConnectorMissingRequiredAnnotationError(PostgresConnectorError, AnnotationValidatorMissedRequiredException):
    pass


class PgConnectorAnnotationEmptyValueError(PostgresConnectorError, AnnotationValidatorEmptyValueException):
    pass
