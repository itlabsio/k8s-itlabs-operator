from dataclasses import dataclass
from typing import Optional, Dict


@dataclass
class PgInstanceDto:
    pg_instance_name: str
    vault_path: str


@dataclass
class PgConnector:
    def __init__(self):
        self.instances: Dict[str, str] = {}

    def get_vaultpath_by_name(self, instance_name: str) -> Optional[str]:
        return self.instances.get(instance_name)

    def add_pg_instance(self, pg_instance: PgInstanceDto):
        self.instances[pg_instance.pg_instance_name] = pg_instance.vault_path


@dataclass
class PgConnectorMicroserviceDto:
    pg_instance_name: str
    vault_path: str
    db_name: str
    db_username: str


@dataclass
class PgConnectorInstanceSecretDto:
    db_name: str
    user: str
    password: str
    host: str
    port: int
    db_kube_domain: str
