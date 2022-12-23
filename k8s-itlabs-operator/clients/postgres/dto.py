from dataclasses import dataclass


@dataclass
class PgConnectorDbSecretDto:
    db_name: str
    user: str
    password: str
    host: str
    port: int
