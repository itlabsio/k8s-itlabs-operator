from dataclasses import dataclass


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
    broker_host: str
    broker_port: int
    url: str
    username: str
    password: str
