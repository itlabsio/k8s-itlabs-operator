from dataclasses import dataclass


@dataclass
class SentryApiSecretDto:
    api_token: str
    api_url: str
    api_organization: str


@dataclass
class SentryMsSecretDto:
    dsn: str
    project_slug: str


@dataclass
class SentryConnector:
    url: str
    token: str
    organization: str


@dataclass
class SentryConnectorMicroserviceDto:
    sentry_instance_name: str
    vault_path: str
    project: str
    team: str
    environment: str
