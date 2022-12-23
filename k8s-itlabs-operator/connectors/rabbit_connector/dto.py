from dataclasses import dataclass
from typing import Dict, Optional


@dataclass
class RabbitApiSecretDto:
    api_url: str
    api_user: str
    api_password: str
    broker_host: str
    broker_port: int


@dataclass
class RabbitMsSecretDto:
    broker_host: str
    broker_port: int
    broker_user: str
    broker_password: str
    broker_vhost: str
    broker_url: str


@dataclass
class RabbitConnectorMicroserviceDto:
    rabbit_instance_name: str
    vault_path: str
    username: str
    vhost: str


@dataclass
class RabbitConnector:
    def __init__(self):
        self.instances: Dict[str, str] = {}

    def get_vaultpath_by_name(self, instance_name: str) -> Optional[str]:
        return self.instances.get(instance_name)

    def add_rabbit_instance(self, name: str, vault_path: str):
        self.instances[name] = vault_path
