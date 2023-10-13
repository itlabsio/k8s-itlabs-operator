import logging
from abc import ABCMeta, abstractmethod
from typing import Iterable

import psycopg2
from psycopg2 import sql

from clients.postgres.dto import PgConnectorDbSecretDto
from clients.postgres.exceptions import PgQueryValidationError
from exceptions import InfrastructureServiceProblem

logger = logging.getLogger('postgresclient')


class AbstractPostgresClient:
    __metaclass__ = ABCMeta

    @abstractmethod
    def is_user_exist(self, user: str) -> bool:
        raise NotImplementedError

    @abstractmethod
    def is_user_grantee(self, database: str, user: str) -> bool:
        raise NotImplementedError

    @abstractmethod
    def is_database_exist(self, db_name: str) -> bool:
        raise NotImplementedError

    @abstractmethod
    def create_user(self, user: str, password: str):
        raise NotImplementedError

    @abstractmethod
    def alter_user_password(self, user: str, password: str):
        raise NotImplementedError

    @abstractmethod
    def create_database(self, db_name: str, user: str):
        raise NotImplementedError

    @abstractmethod
    def grant_all_privileges(self, db_name: str, user: str):
        raise NotImplementedError

    @abstractmethod
    def grant_user_to_admin(self, user: str):
        raise NotImplementedError

    @abstractmethod
    def grant_access_on_select(self, grantor_name: str, grantee_name: str):
        raise NotImplementedError


class PostgresClient(AbstractPostgresClient):

    def __init__(self, pg_connector_secret_dto: PgConnectorDbSecretDto):
        self.connection_data = pg_connector_secret_dto

    def _execute_query_v2(self, query: str, *, identifiers: Iterable[str] = None,
                          values: Iterable[str] = None):
        """
        Execute sql-query in database and returns execution result.

        :param query: sql-query that can contains identifiers and arguments
            (https://www.psycopg.org/docs/sql.html#module-psycopg2.sql).

        :param identifiers: list of sql identifiers (names of tables, fields).
            Using {}-style placeholders in query.

        :param values: list of argument values.
            Using %-style placeholders in query.

        :return: Returns list of values.
        """
        conn = None
        if values is None:
            values = []
        if identifiers is None:
            query = sql.SQL(query)
        else:
            if not identifiers:
                raise PgQueryValidationError(f'sql identifiers are mandatory but empty. '
                                             f'Please check variables name in Vault, identifiers: {identifiers}')
            query_identifiers = [sql.Identifier(i) for i in identifiers]
            query = sql.SQL(query).format(*query_identifiers)
        try:
            logger.info('Connecting to the PostgreSQL database...')
            conn = psycopg2.connect(database=self.connection_data.db_name,
                                    user=self.connection_data.user,
                                    password=self.connection_data.password,
                                    host=self.connection_data.host,
                                    port=self.connection_data.port)
            conn.autocommit = True
            cursor = conn.cursor()

            cursor.execute(query, values)

            try:
                results = cursor.fetchall()
            except psycopg2.ProgrammingError:
                results = []
        except (Exception, psycopg2.DatabaseError) as e:
            raise InfrastructureServiceProblem('Postgres', e)
        else:
            return results
        finally:
            if conn is not None:
                conn.close()
                logger.info('Database connection closed.')

    def is_user_exist(self, user: str) -> bool:
        query = """SELECT * FROM pg_catalog.pg_user u WHERE u.usename = %s;"""
        return bool(self._execute_query_v2(query, values=[user]))

    def is_user_grantee(self, database: str, user: str) -> bool:
        query = """
            SELECT 1 FROM information_schema.table_privileges WHERE
                grantee = %s
                AND table_catalog = %s
                AND privilege_type = 'SELECT'
            UNION
            SELECT 1
            FROM pg_default_acl acl
            join pg_namespace namespace on namespace.oid = acl.defaclnamespace
            WHERE acl.defaclacl::text ILIKE %s;
        """
        return bool(self._execute_query_v2(
            query,
            values=[user, database, f"%{user}=r/{database}%"],
        ))

    def is_database_exist(self, db_name: str) -> bool:
        query = """SELECT * FROM pg_catalog.pg_database db WHERE db.datname = %s;"""
        return bool(self._execute_query_v2(query, values=[db_name]))

    def create_user(self, user: str, password: str):
        query = """CREATE USER {} WITH ENCRYPTED PASSWORD %s;"""
        self._execute_query_v2(query, identifiers=[user], values=[password])

    def alter_user_password(self, user: str, password: str):
        query = """ALTER USER {} WITH ENCRYPTED PASSWORD %s;"""
        self._execute_query_v2(query, identifiers=[user], values=[password])

    def create_database(self, db_name: str, user: str):
        self._grant_user_to_another(
            user=user, another_user=self.connection_data.user
        )
        self._create_database(db_name=db_name, owner=user)
        self._revoke_user_from_another(
            user=user, another_user=self.connection_data.user
        )
        self.grant_all_privileges(db_name=db_name, user=user)

    def _create_database(self, db_name: str, owner: str):
        query = """CREATE DATABASE {} WITH OWNER = %s;"""
        self._execute_query_v2(query, identifiers=[db_name], values=[owner])

    def grant_all_privileges(self, db_name: str, user: str):
        query = """GRANT ALL PRIVILEGES ON DATABASE {} TO {};"""
        self._execute_query_v2(query, identifiers=[db_name, user])

    def grant_user_to_admin(self, user: str):
        self._grant_user_to_another(user=user, another_user='postgres')

    def _grant_user_to_another(self, user: str, another_user: str):
        query = """GRANT {} TO {};"""
        self._execute_query_v2(query, identifiers=[user, another_user])

    def _revoke_user_from_another(self, user: str, another_user: str):
        query = """REVOKE {} FROM {};"""
        self._execute_query_v2(query, identifiers=[user, another_user])

    def grant_access_on_select(self, grantor_name: str, grantee_name: str):
        self._grant_user_to_another(grantor_name, self.connection_data.user)
        self._grant_access_on_select(grantor_name, grantee_name)
        self._revoke_user_from_another(
            user=grantor_name, another_user=self.connection_data.user
        )

    def _grant_access_on_select(self, grantor_name: str, grantee_name: str):
        query = """
            GRANT USAGE ON SCHEMA public TO {1};

            GRANT SELECT ON ALL TABLES IN SCHEMA public TO {1};
            GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO {1};

            ALTER DEFAULT PRIVILEGES GRANT SELECT ON TABLES TO {1};
            ALTER DEFAULT PRIVILEGES GRANT SELECT ON SEQUENCES TO {1};

            ALTER DEFAULT PRIVILEGES IN SCHEMA public
                GRANT SELECT ON TABLES TO {1};
            ALTER DEFAULT PRIVILEGES IN SCHEMA public
                GRANT SELECT ON SEQUENCES TO {1};

            ALTER DEFAULT PRIVILEGES FOR USER {0} IN SCHEMA public
                GRANT SELECT ON TABLES TO {1};
            ALTER DEFAULT PRIVILEGES FOR USER {0} IN SCHEMA public
                GRANT SELECT ON SEQUENCES TO {1};
        """
        self._execute_query_v2(query, identifiers=[grantor_name, grantee_name])
