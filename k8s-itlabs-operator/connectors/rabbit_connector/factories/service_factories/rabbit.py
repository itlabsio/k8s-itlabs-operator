from clients.rabbit.rabbitclient import RabbitClient
from connectors.rabbit_connector.dto import RabbitApiSecretDto
from connectors.rabbit_connector.services.rabbit import AbstractRabbitService, RabbitService


class RabbitServiceFactory:
    @classmethod
    def create_rabbit_service(cls, rabbit_api_cred: RabbitApiSecretDto) -> AbstractRabbitService:
        rabbit_client = RabbitClient(
            url=rabbit_api_cred.api_url,
            user=rabbit_api_cred.api_user,
            password=rabbit_api_cred.api_password
        )
        return RabbitService(rabbit_client=rabbit_client)
