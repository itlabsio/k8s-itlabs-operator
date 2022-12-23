from dataclasses import dataclass


@dataclass
class KeycloakConnector:
    url: str
    realm: str
    username_secret: str
    password_secret: str


@dataclass
class KeycloakConnectorMicroserviceDto:
    keycloak_instance_name: str
    vault_path: str
    client_id: str


@dataclass
class KeycloakApiSecretDto:
    url: str
    realm: str
    username: str
    password: str


@dataclass
class KeycloakMsSecretDto:
    client_id: str
    secret: str
