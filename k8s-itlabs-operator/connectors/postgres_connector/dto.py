from dataclasses import dataclass


@dataclass
class PgConnector:
    host: str
    port: int
    database: str
    username: str
    password: str
    readonly_username: str | None = None


@dataclass
class PgConnectorMicroserviceDto:
    pg_instance_name: str
    vault_path: str
    db_name: str
    db_username: str
    grant_access_for_readonly_user: bool | None = None


@dataclass
class PgConnectorInstanceSecretDto:
    db_name: str
    user: str
    password: str
    host: str
    port: int
    readonly_username: str | None = None
