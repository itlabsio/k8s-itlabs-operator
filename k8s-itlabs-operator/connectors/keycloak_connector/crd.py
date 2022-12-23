from dataclasses import dataclass

from kubernetes.client import V1ObjectMeta


@dataclass
class KeycloakConnectorSpec:
    url: str
    realm: str
    username: str
    password: str


@dataclass
class KeycloakConnectorCrd:
    api_version: str
    kind: str
    metadata: V1ObjectMeta
    spec: KeycloakConnectorSpec
