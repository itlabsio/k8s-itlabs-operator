from dataclasses import dataclass
from typing import List

from kubernetes.client import V1ObjectMeta


@dataclass
class PostgresConnectorSpec:
    name: str
    vaultpath: str


@dataclass
class PostgresConnectorCrd:
    api_version: str
    kind: str
    metadata: V1ObjectMeta
    spec: List[PostgresConnectorSpec]
