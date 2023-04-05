from typing import Optional

from connectors.sentry_connector.dto import SentryConnector, SentryMsSecretDto, SentryApiSecretDto
from connectors.sentry_connector.services.vault import AbstractVaultService


class KubernetesServiceMocker:
    @staticmethod
    def mock_get_sentry_connector(mocker, sentry_connector: Optional[SentryConnector] = None):
        return mocker.patch(
            "connectors.sentry_connector.services.kubernetes.KubernetesService.get_sentry_connector",
            return_value=sentry_connector
        )


class MockedVaultService(AbstractVaultService):
    def __init__(self, sentry_api_token: Optional[str] = None,
                 sentry_ms_secret: Optional[SentryMsSecretDto] = None):
        self.sentry_api_token = sentry_api_token
        self.sentry_ms_secret = sentry_ms_secret

        self.get_sentry_ms_credentials_calls_total = 0
        self.get_vault_env_value_calls_total = 0
        self.create_ms_sentry_credentials_calls_total = 0

    def get_sentry_ms_credentials(self, vault_path: str) -> SentryMsSecretDto:
        self.get_sentry_ms_credentials_calls_total += 1
        return self.sentry_ms_secret

    def get_vault_env_value(self, vault_path: str, vault_key: str) -> str:
        self.get_vault_env_value_calls_total += 1
        return f"{vault_path}#{vault_key}"

    def create_ms_sentry_credentials(self, vault_path: str, sentry_ms_cred: SentryMsSecretDto):
        self.create_ms_sentry_credentials_calls_total += 1

    def unvault_sentry_connector(self, sentry_connector: SentryConnector) -> Optional[SentryApiSecretDto]:
        pass
