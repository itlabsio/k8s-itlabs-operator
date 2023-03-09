from clients.postgres.postgresclient import PostgresClient
from connectors.postgres_connector.dto import PgConnectorInstanceSecretDto
from connectors.postgres_connector.factories.dto_factory import PgConnectorDbSecretDtoFactory
from connectors.postgres_connector.services.postgres import AbstractPostgresService, PostgresService


class PostgresServiceFactory:
    @classmethod
    def create_pg_service(cls, pg_instance_cred: PgConnectorInstanceSecretDto) -> AbstractPostgresService:
        pg_con_secret_dto = PgConnectorDbSecretDtoFactory.dto_from_pg_instance_cred(pg_instance_cred=pg_instance_cred)
        pg_client = PostgresClient(pg_connector_secret_dto=pg_con_secret_dto)
        return PostgresService(pg_client=pg_client)
