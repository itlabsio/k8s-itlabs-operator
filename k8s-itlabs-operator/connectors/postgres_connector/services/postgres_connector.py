from clients.postgres.dto import PgConnectorDbSecretDto
from connectors.postgres_connector import specifications
from connectors.postgres_connector.dto import PgConnectorMicroserviceDto, PgConnectorInstanceSecretDto
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

    def on_create_deployment(self, ms_pg_con: PgConnectorMicroserviceDto):
        pg_con_crds = KubernetesService.get_pg_connector()
        if not pg_con_crds:
            raise PgConnectorCrdDoesNotExist()
        vault_path = pg_con_crds.get_vaultpath_by_name(ms_pg_con.pg_instance_name)
        if not vault_path:
            raise UnknownVaultPathInPgConnector()
        pg_instance_creds = self.vault_service.get_pg_instance_credentials(vault_path)
        pg_service = PostgresServiceFactory.create_pg_service(pg_instance_creds)
        db_creds = self.get_or_create_db_credentials(pg_instance_creds, ms_pg_con)
        pg_service.create_database(db_creds)

    @staticmethod
    def is_pg_conn_used_by_object(annotations: dict) -> bool:
        return all(annotation_name in annotations for annotation_name in PG_CON_REQUIRED_ANNOTATION_NAMES)

    def get_or_create_db_credentials(self, pg_instance_creds: PgConnectorInstanceSecretDto,
                                     ms_pg_con: PgConnectorMicroserviceDto) -> PgConnectorDbSecretDto:
        pg_ms_creds = self.vault_service.get_pg_ms_credentials(ms_pg_con.vault_path)
        if pg_ms_creds:
            if pg_ms_creds.user != ms_pg_con.db_username:
                raise NotMatchingUsernames()
            if pg_ms_creds.db_name != ms_pg_con.db_name:
                raise NotMatchingDbNames()
        else:
            pg_ms_creds = PgConnectorDbSecretDtoFactory.dto_from_ms_pg_con(pg_instance_creds, ms_pg_con)
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

    @classmethod
    def is_postgres_connector_enabled(cls):
        enabled = False
        try:
            if KubernetesService.get_pg_connector():
                enabled = True
        finally:
            return enabled
