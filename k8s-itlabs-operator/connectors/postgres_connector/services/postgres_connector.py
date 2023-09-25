from itertools import chain

from clients.postgres.dto import PgConnectorDbSecretDto
from connectors.postgres_connector import specifications
from connectors.postgres_connector.dto import PgConnectorMicroserviceDto, PgConnectorInstanceSecretDto
from connectors.postgres_connector.exceptions import PgConnectorCrdDoesNotExist, \
    UnknownVaultPathInPgConnector, \
    NotMatchingUsernames, NotMatchingDbNames, \
    PgConnectorReadonlyUsernameIsNotSet, PgConnectorReadonlyUsernameDoesNotExist
from connectors.postgres_connector.factories.dto_factory import PgConnectorDbSecretDtoFactory
from connectors.postgres_connector.factories.service_factories.postgres import PostgresServiceFactory
from connectors.postgres_connector.services.kubernetes import KubernetesService
from connectors.postgres_connector.services.vault import AbstractVaultService
from utils.concurrency import ConnectorSourceLock
from utils.hashing import generate_hash


class PostgresConnectorService:
    def __init__(self, vault_service: AbstractVaultService):
        self.vault_service = vault_service

    def on_create_deployment(self, ms_pg_con: PgConnectorMicroserviceDto):
        pg_connector = KubernetesService.get_pg_connector(ms_pg_con.pg_instance_name)
        if not pg_connector:
            raise PgConnectorCrdDoesNotExist(
                f"Postgres Custom Resource `{ms_pg_con.pg_instance_name}`"
                " does not exist"
            )

        pg_instance_cred = self.vault_service.unvault_pg_connector(pg_connector)
        if not pg_instance_cred:
            raise UnknownVaultPathInPgConnector(
                "Couldn't getting root credentials for connecting to Postgres"
            )

        pg_service = PostgresServiceFactory.create_pg_service(pg_instance_cred)
        source_hash = self.generate_source_hash(
            host=pg_instance_cred.host,
            port=pg_instance_cred.port,
            database=ms_pg_con.db_name,
            username=ms_pg_con.db_username,
        )
        with ConnectorSourceLock(source_hash):
            db_creds = self.get_or_create_db_credentials(pg_instance_cred, ms_pg_con)
            pg_service.create_database(db_creds)

            if ms_pg_con.grant_access_for_readonly_user:

                if not pg_instance_cred.readonly_username:
                    raise PgConnectorReadonlyUsernameIsNotSet(
                        f"`readonly` username is not set in Custom Resource "
                        f"{ms_pg_con.pg_instance_name}"
                    )

                if not pg_service.is_user_exist(pg_instance_cred.readonly_username):
                    raise PgConnectorReadonlyUsernameDoesNotExist(
                        f"{pg_instance_cred.readonly_username} does not exist "
                        f"in {ms_pg_con.pg_instance_name}"
                    )

                if pg_service.is_user_grantee(db_creds.db_name, pg_instance_cred.readonly_username):
                    return

                pg_service.grant_access_on_select(
                    db_creds.user, db_creds.password, db_creds.db_name,
                    pg_instance_cred.readonly_username
                )

    @staticmethod
    def generate_source_hash(
            host: str, port: int, database: str, username: str
    ) -> str:
        return generate_hash(host, port, database, username)

    @staticmethod
    def any_containers_contain_required_envs(spec: dict) -> bool:
        all_containers = chain(
            spec.get("containers", []),
            spec.get("initContainers", [])
        )

        required_envs = set(env for env, _ in specifications.DATABASE_VAR_NAMES)

        for container in all_containers:
            envs = set(e.get("name") for e in container.get("env", []))
            if (envs & required_envs) == required_envs:
                return True
        return False

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
