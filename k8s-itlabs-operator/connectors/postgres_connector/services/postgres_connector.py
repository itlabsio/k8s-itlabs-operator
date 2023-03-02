from typing import Optional

from clients.postgres.dto import PgConnectorDbSecretDto
from connectors.postgres_connector import specifications
from connectors.postgres_connector.dto import PgConnectorMicroserviceDto, \
    PgConnectorInstanceSecretDto, PgConnector
from connectors.postgres_connector.exceptions import PgConnectorCrdDoesNotExist, UnknownVaultPathInPgConnector, \
    NotMatchingUsernames, NotMatchingDbNames
from connectors.postgres_connector.factories.dto_factory import PgConnectorDbSecretDtoFactory
from connectors.postgres_connector.factories.service_factories.postgres import PostgresServiceFactory
from connectors.postgres_connector.services.kubernetes import KubernetesService
from connectors.postgres_connector.services.vault import AbstractVaultService
from connectors.postgres_connector.specifications import PG_CON_REQUIRED_ANNOTATION_NAMES


class PostgresConnectorService:
    def __init__(self, vault_service: AbstractVaultService):
        self.vault_service = vault_service

    def _get_pg_instance_cred(self, pg_conn_crd: PgConnector) -> Optional[PgConnectorInstanceSecretDto]:
        username = self.vault_service.get_pg_instance_secret(pg_conn_crd.username)
        password = self.vault_service.get_pg_instance_secret(pg_conn_crd.password)

        if not(username and password):
            return None

        return PgConnectorInstanceSecretDto(
            host=pg_conn_crd.host,
            port=pg_conn_crd.port,
            db_name=pg_conn_crd.database,
            user=username,
            password=password,
        )

    def on_create_deployment(self, ms_pg_con: PgConnectorMicroserviceDto):
        pg_con_crd = KubernetesService.get_pg_connector(ms_pg_con.pg_instance_name)
        if not pg_con_crd:
            raise PgConnectorCrdDoesNotExist()

        pg_instance_cred = self._get_pg_instance_cred(pg_con_crd)
        if not pg_instance_cred:
            raise UnknownVaultPathInPgConnector()

        pg_service = PostgresServiceFactory.create_pg_service(pg_instance_cred)
        db_creds = self.get_or_create_db_credentials(pg_instance_cred, ms_pg_con)
        pg_service.create_database(db_creds)

    @staticmethod
    def is_pg_conn_used_by_object(annotations: dict) -> bool:
        return all(annotation_name in annotations for annotation_name in PG_CON_REQUIRED_ANNOTATION_NAMES)

    def get_or_create_db_credentials(self, pg_instance_cred: PgConnectorInstanceSecretDto,
                                     ms_pg_con: PgConnectorMicroserviceDto) -> PgConnectorDbSecretDto:
        pg_ms_creds = self.vault_service.get_pg_ms_credentials(ms_pg_con.vault_path)
        if pg_ms_creds:
            if pg_ms_creds.user != ms_pg_con.db_username:
                raise NotMatchingUsernames()
            if pg_ms_creds.db_name != ms_pg_con.db_name:
                raise NotMatchingDbNames()
        else:
            pg_ms_creds = PgConnectorDbSecretDtoFactory.dto_from_ms_pg_con(pg_instance_cred, ms_pg_con)
            self.vault_service.create_pg_ms_credentials(ms_pg_con.vault_path, pg_ms_creds)
        return pg_ms_creds

    def mutate_containers(self, spec: dict, ms_pg_con: PgConnectorMicroserviceDto) -> bool:
        mutated = False
        for container in spec.get('containers', []):
            mutated = self.mutate_container(container, mutated, ms_pg_con.vault_path)
        for init_container in spec.get('initContainers', []):
            mutated = self.mutate_container(init_container, mutated, ms_pg_con.vault_path)
        return mutated

    def mutate_container(self, container: dict, mutated: bool, vault_path: str) -> bool:
        envs = container.get('env')
        if not envs:
            envs = []
        for envvar_name, vault_key in specifications.DATABASE_VAR_NAMES:
            if envvar_name not in [env.get('name') for env in envs]:
                envs.append({
                    "name": envvar_name,
                    "value": self.vault_service.get_vault_env_value(vault_path, vault_key)
                })
                mutated = True
        if mutated:
            container['env'] = envs
        return mutated
