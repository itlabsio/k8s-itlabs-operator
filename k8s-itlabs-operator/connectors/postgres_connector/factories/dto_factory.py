from typing import List

from clients.postgres.dto import PgConnectorDbSecretDto
from connectors.postgres_connector import specifications
from connectors.postgres_connector.crd import PostgresConnectorSpec, PostgresConnectorCrd
from connectors.postgres_connector.dto import PgInstanceDto, PgConnectorMicroserviceDto, PgConnector, \
    PgConnectorInstanceSecretDto
from connectors.postgres_connector.specifications import PG_INSTANCE_NAME_ANNOTATION, VAULTPATH_NAME_ANNOTATION, \
    DB_NAME_ANNOTATION, USER_NAME_ANNOTATION, APP_NAME_LABEL
from utils.passgen import generate_password


class PgInstanceDtoFactory:
    @classmethod
    def dto_from_pg_con_spec_crd(cls, pg_con_spec: PostgresConnectorSpec) -> PgInstanceDto:
        return PgInstanceDto(
            pg_instance_name=pg_con_spec.name,
            vault_path=pg_con_spec.vaultpath
        )

    @classmethod
    def dto_from_pg_con_ms_dto(cls, pg_con_ms_dto: PgConnectorMicroserviceDto):
        return PgInstanceDto(
            pg_instance_name=pg_con_ms_dto.pg_instance_name,
            vault_path=pg_con_ms_dto.vault_path
        )


class PgConnectorFactory:
    @classmethod
    def dto_from_pg_con_crds(cls, pg_con_crds: List[PostgresConnectorCrd]) -> PgConnector:
        pg_con_dto = PgConnector()
        for pg_con_crd in pg_con_crds:
            for spec in pg_con_crd.spec:
                pg_instance_dto = PgInstanceDtoFactory.dto_from_pg_con_spec_crd(pg_con_spec=spec)
                pg_con_dto.add_pg_instance(pg_instance_dto)
        return pg_con_dto


class PgConnectorMicroserviceDtoFactory:
    @classmethod
    def dto_from_annotations(cls, annotations: dict, labels: dict) -> PgConnectorMicroserviceDto:
        default_name = labels.get(APP_NAME_LABEL)
        return PgConnectorMicroserviceDto(
            pg_instance_name=annotations.get(PG_INSTANCE_NAME_ANNOTATION),
            vault_path=annotations.get(VAULTPATH_NAME_ANNOTATION),
            db_name=annotations.get(DB_NAME_ANNOTATION, default_name),
            db_username=annotations.get(USER_NAME_ANNOTATION, default_name)
        )


class PgConnectorDbSecretDtoFactory:
    @classmethod
    def dto_from_ms_pg_con(cls, pg_instance_creds: PgConnectorInstanceSecretDto,
                           ms_pg_con: PgConnectorMicroserviceDto) -> PgConnectorDbSecretDto:
        """Create PgConnectorDbSecretDto for microservice database connection"""
        return PgConnectorDbSecretDto(
            db_name=ms_pg_con.db_name,
            user=ms_pg_con.db_username,
            password=generate_password(),
            host=pg_instance_creds.db_kube_domain,
            port=pg_instance_creds.port
        )

    @classmethod
    def dto_from_pg_instance_cred(cls, pg_instance_creds: PgConnectorInstanceSecretDto) -> PgConnectorDbSecretDto:
        """Create PgConnectorDbSecretDto for database connection in Postgres"""
        return PgConnectorDbSecretDto(
            db_name=pg_instance_creds.db_name,
            user=pg_instance_creds.user,
            password=pg_instance_creds.password,
            host=pg_instance_creds.host,
            port=pg_instance_creds.port
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
    def dto_from_dict(cls, data: dict) -> PgConnectorInstanceSecretDto:
        return PgConnectorInstanceSecretDto(
            db_name=data.get(specifications.DATABASE_NAME_KEY),
            user=data.get(specifications.DATABASE_USER_KEY),
            password=data.get(specifications.DATABASE_PASSWORD_KEY),
            host=data.get(specifications.DATABASE_HOST_KEY),
            port=int(data.get(specifications.DATABASE_PORT_KEY)),
            db_kube_domain=data.get(specifications.DATABASE_KUBE_DOMAIN_KEY),
        )
