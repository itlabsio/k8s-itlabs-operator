from typing import Optional

from clients.rabbit.rabbitclient import AbstractRabbitClient


class MockedRabbitClient(AbstractRabbitClient):
    def __init__(self):
        self.delete_user_call_count = 0
        self.delete_vhost_call_count = 0

    def get_rabbit_user(self, user: str):
        pass

    def create_rabbit_user(self, user: str, password: str):
        pass

    def delete_rabbit_user(self, user: str):
        self.delete_user_call_count += 1

    def get_rabbit_vhost(self, vhost: str):
        pass

    def create_rabbit_vhost(self, vhost: str):
        pass

    def delete_rabbit_vhost(self, vhost: str):
        self.delete_vhost_call_count += 1

    def get_user_vhost_permissions(self, user, vhost):
        pass

    def create_user_vhost_permissions(self, user, vhost):
        pass


class RabbitClientFactoryMocker:
    @staticmethod
    def mock_create_rabbit_client(mocker, rabbit_client: Optional[AbstractRabbitClient] = None):
        if not rabbit_client:
            rabbit_client = MockedRabbitClient()
        return mocker.patch('services.rabbit.factories.client_factory.RabbitClientFactory.create_rabbit_client',
                            return_value=rabbit_client)
