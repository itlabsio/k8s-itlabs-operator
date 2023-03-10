from dataclasses import dataclass

from kubernetes.client import V1ObjectMeta


@dataclass
class SentryConnectorSpec:
    url: str
    token: str
    organization: str


@dataclass
class SentryConnectorCrd:
    api_version: str
    kind: str
    metadata: V1ObjectMeta
    spec: SentryConnectorSpec
