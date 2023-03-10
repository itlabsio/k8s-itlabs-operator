from dataclasses import dataclass

from kubernetes.client import V1ObjectMeta


@dataclass
class RabbitConnectorSpec:
    broker_host: str
    broker_port: int
    url: str
    username: str
    password: str


@dataclass
class RabbitConnectorCrd:
    api_version: str
    kind: str
    metadata: V1ObjectMeta
    spec: RabbitConnectorSpec
