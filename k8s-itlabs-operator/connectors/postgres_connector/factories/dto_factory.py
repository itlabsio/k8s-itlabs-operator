from clients.postgres.dto import PgConnectorDbSecretDto
from connectors.postgres_connector import specifications
from connectors.postgres_connector.crd import PostgresConnectorCrd
from connectors.postgres_connector.dto import PgConnectorMicroserviceDto, PgConnector, \
    PgConnectorInstanceSecretDto
from connectors.postgres_connector.exceptions import PgConnectorAnnotationEmptyValueError, \
    PgConnectorMissingRequiredAnnotationError
from connectors.postgres_connector.specifications import PG_INSTANCE_NAME_ANNOTATION, VAULTPATH_NAME_ANNOTATION, \
    DB_NAME_ANNOTATION, USER_NAME_ANNOTATION, APP_NAME_LABEL
from utils.passgen import generate_password
from validation.annotations_validator import AnnotationValidator


class PgConnectorFactory:
    @classmethod
    def dto_from_pg_con_crds(cls, pg_con_crd: PostgresConnectorCrd) -> PgConnector:
        return PgConnector(
            host=pg_con_crd.spec.host,
            port=pg_con_crd.spec.port,
            database=pg_con_crd.spec.database,
            username=pg_con_crd.spec.username,
            password=pg_con_crd.spec.password,
        )


class PgAnnotationValidator(AnnotationValidator):
    required_annotation_names = specifications.PG_CON_REQUIRED_ANNOTATION_NAMES
    on_missing_required_annotation_error = PgConnectorMissingRequiredAnnotationError
    not_empty_annotation_names = specifications.PG_CON_ANNOTATION_NAMES
    on_empty_value_annotation_error = PgConnectorAnnotationEmptyValueError


class PgConnectorMicroserviceDtoFactory:
    @classmethod
    def dto_from_annotations(cls, annotations: dict, labels: dict) -> PgConnectorMicroserviceDto:
        pg_annotations = {}
        default_name = labels.get(APP_NAME_LABEL, "")
        for key in specifications.PG_CON_ANNOTATION_NAMES:
            if key == DB_NAME_ANNOTATION:
                pg_annotations[key] = annotations.get(DB_NAME_ANNOTATION, default_name)
            elif key == USER_NAME_ANNOTATION:
                pg_annotations[key] = annotations.get(USER_NAME_ANNOTATION, default_name)
            elif key in annotations:
                pg_annotations[key] = annotations[key]
        PgAnnotationValidator.validate(annotations=pg_annotations)
        return PgConnectorMicroserviceDto(
            pg_instance_name=pg_annotations.get(PG_INSTANCE_NAME_ANNOTATION),
            vault_path=pg_annotations.get(VAULTPATH_NAME_ANNOTATION),
            db_name=pg_annotations.get(DB_NAME_ANNOTATION),
            db_username=pg_annotations.get(USER_NAME_ANNOTATION)
        )


class PgConnectorDbSecretDtoFactory:
    @classmethod
    def dto_from_ms_pg_con(cls, pg_instance_cred: PgConnectorInstanceSecretDto,
                           ms_pg_con: PgConnectorMicroserviceDto) -> PgConnectorDbSecretDto:
        """Create PgConnectorDbSecretDto for microservice database connection"""
        return PgConnectorDbSecretDto(
            db_name=ms_pg_con.db_name,
            user=ms_pg_con.db_username,
            password=generate_password(),
            host=pg_instance_cred.host,
            port=pg_instance_cred.port
        )

    @classmethod
    def dto_from_pg_instance_cred(cls, pg_instance_cred: PgConnectorInstanceSecretDto) -> PgConnectorDbSecretDto:
        """Create PgConnectorDbSecretDto for database connection in Postgres"""
        return PgConnectorDbSecretDto(
            db_name=pg_instance_cred.db_name,
            user=pg_instance_cred.user,
            password=pg_instance_cred.password,
            host=pg_instance_cred.host,
            port=pg_instance_cred.port
        )

    @classmethod
    def dto_from_dict(cls, data: dict) -> PgConnectorDbSecretDto:
        return PgConnectorDbSecretDto(
            db_name=data.get(specifications.DATABASE_NAME_KEY),
            user=data.get(specifications.DATABASE_USER_KEY),
            password=data.get(specifications.DATABASE_PASSWORD_KEY),
            host=data.get(specifications.DATABASE_HOST_KEY),
            port=int(data.get(specifications.DATABASE_PORT_KEY)),
        )

    @classmethod
    def vault_data_from_dto(cls, pg_con_db_cred: PgConnectorDbSecretDto) -> dict:
        return {
            specifications.DATABASE_NAME_KEY: pg_con_db_cred.db_name,
            specifications.DATABASE_USER_KEY: pg_con_db_cred.user,
            specifications.DATABASE_PASSWORD_KEY: pg_con_db_cred.password,
            specifications.DATABASE_HOST_KEY: pg_con_db_cred.host,
            specifications.DATABASE_PORT_KEY: str(pg_con_db_cred.port),
        }


class PgConnectorInstanceSecretDtoFactory:
    @classmethod
    def api_secret_dto_from_connector(cls, pg_connector: PgConnector) -> PgConnectorInstanceSecretDto:
        return PgConnectorInstanceSecretDto(
            host=pg_connector.host,
            port=pg_connector.port,
            db_name=pg_connector.database,
            user=pg_connector.username,
            password=pg_connector.password,
        )
