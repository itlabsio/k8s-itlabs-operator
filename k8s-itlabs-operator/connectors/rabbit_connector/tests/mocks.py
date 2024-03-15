from typing import Optional

from connectors.rabbit_connector.dto import (
    RabbitApiSecretDto,
    RabbitConnector,
    RabbitMsSecretDto,
)
from connectors.rabbit_connector.services.kubernetes import (
    AbstractKubernetesService,
)
from connectors.rabbit_connector.services.rabbit import AbstractRabbitService
from connectors.rabbit_connector.services.vault import AbstractVaultService


class MockedRabbitService(AbstractRabbitService):
    def __init__(self):
        self.delete_rabbit_call_count = 0
        self.configure_rabbit_call_count = 0

    def delete_rabbit(self, user_name: str, vhost_name: str):
        self.delete_rabbit_call_count += 1

    def configure_rabbit(self, secret: RabbitMsSecretDto):
        self.configure_rabbit_call_count += 1


class RabbitServiceFactoryMocker:
    @staticmethod
    def mock_create_rabbit_service(mocker):
        return mocker.patch(
            "connectors.rabbit_connector.factories.service_factories.rabbit.RabbitServiceFactory.create_rabbit_service",
            return_value=MockedRabbitService(),
        )


class MockedVaultService(AbstractVaultService):
    def __init__(self, rabbit_api_cred: Optional[RabbitApiSecretDto] = None):
        self.rabbit_api_cred = rabbit_api_cred
        self.get_vault_env_value_call_count = 0

    def get_rabbit_ms_credentials(self, vault_path: str) -> RabbitMsSecretDto:
        pass

    def create_ms_rabbit_credentials(
        self, vault_path: str, rabbit_ms_cred: RabbitMsSecretDto
    ):
        pass

    def get_vault_env_value(self, vault_path: str, vault_key: str) -> str:
        self.get_vault_env_value_call_count += 1
        return f"{vault_path}#{vault_key}"

    def unvault_rabbit_connector(
        self, rabbit_connector: RabbitConnector
    ) -> Optional[RabbitApiSecretDto]:
        return self.rabbit_api_cred


class KubernetesServiceMocker:
    @staticmethod
    def mock_get_rabbit_connector(
        mocker, rabbit_connector: Optional[RabbitConnector] = None
    ):
        return mocker.patch(
            "connectors.rabbit_connector.services.kubernetes.KubernetesService.get_rabbit_connector",
            return_value=rabbit_connector,
        )


class MockKubernetesService(AbstractKubernetesService):
    @classmethod
    def get_rabbit_connector(cls, name: str) -> Optional[RabbitConnector]:
        return RabbitConnector(
            broker_host="rabbit.default",
            broker_port=5672,
            url="https://rabbit.local",
            username="vault:secret/data/infrastructure/rabbit#USERNAME",
            password="vault:secret/data/infrastructure/rabbit#PASSWORD",
        )
