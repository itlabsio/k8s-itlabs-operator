from dataclasses import dataclass
from typing import List

from kubernetes.client import V1ObjectMeta


@dataclass
class RabbitConnectorSpec:
    name: str
    vaultpath: str


@dataclass
class RabbitConnectorCrd:
    api_version: str
    kind: str
    metadata: V1ObjectMeta
    spec: List[RabbitConnectorSpec]
