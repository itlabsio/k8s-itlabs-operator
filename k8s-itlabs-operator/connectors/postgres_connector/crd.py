from dataclasses import dataclass

from kubernetes.client import V1ObjectMeta


@dataclass
class PostgresConnectorSpec:
    host: str
    port: int
    database: str
    username: str
    password: str


@dataclass
class PostgresConnectorCrd:
    api_version: str
    kind: str
    metadata: V1ObjectMeta
    spec: PostgresConnectorSpec
