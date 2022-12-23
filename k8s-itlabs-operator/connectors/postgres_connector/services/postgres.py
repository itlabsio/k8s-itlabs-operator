import logging
from abc import ABCMeta, abstractmethod

from clients.postgres.dto import PgConnectorDbSecretDto
from clients.postgres.postgresclient import AbstractPostgresClient

logger = logging.getLogger('pg_connector_postgres_service')


class AbstractPostgresService:
    __metaclass__ = ABCMeta

    @abstractmethod
    def create_database(self, db_cred: PgConnectorDbSecretDto):
        raise NotImplementedError


class PostgresService(AbstractPostgresService):
    def __init__(self, pg_client: AbstractPostgresClient):
        self.pg_client = pg_client

    def create_database(self, db_cred: PgConnectorDbSecretDto):
        if self.pg_client.is_user_exist(user=db_cred.user):
            self.pg_client.alter_user_password(user=db_cred.user, password=db_cred.password)
            logger.warning(f"User '{db_cred.user}' already exist, password set from credentials.")
        else:
            self.pg_client.create_user(user=db_cred.user, password=db_cred.password)

        if self.pg_client.is_database_exist(db_name=db_cred.db_name):
            logger.warning(f"Database '{db_cred.db_name}' already exist.")
        else:
            self.pg_client.create_database(db_name=db_cred.db_name, user=db_cred.user)
        self.pg_client.grant_user_to_admin(user=db_cred.user)
