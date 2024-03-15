import logging
from abc import ABCMeta, abstractmethod

from clients.rabbit.rabbitclient import AbstractRabbitClient
from connectors.rabbit_connector.dto import RabbitMsSecretDto

app_logger = logging.getLogger("rabbit_connector_rabbit_service")


class AbstractRabbitService:
    __metaclass__ = ABCMeta

    @abstractmethod
    def configure_rabbit(self, secret: RabbitMsSecretDto):
        raise NotImplementedError


class RabbitService(AbstractRabbitService):

    def __init__(self, rabbit_client: AbstractRabbitClient):
        self.rabbit_client = rabbit_client

    def configure_rabbit(self, secret: RabbitMsSecretDto):
        """
        After execution will be created:
            - user with password;
            - vhost;
        And also will be set rights for user on vhost.

        Attention!
            Password will not be changed is user already exist.

            Rights will not be rewritten is user already has it.
        """
        app_logger.info(
            "Configuring rabbit user '%s', vhost '%s'",
            secret.broker_user,
            secret.broker_vhost,
        )

        rabbit_user_response = self.rabbit_client.get_rabbit_user(
            user=secret.broker_user
        )
        if rabbit_user_response:
            app_logger.warning(
                "User '%s' already exist, password ignored.", secret.broker_user
            )
        else:
            self.rabbit_client.create_rabbit_user(
                user=secret.broker_user, password=secret.broker_password
            )

        rabbit_vhost_response = self.rabbit_client.get_rabbit_vhost("vhost")
        if rabbit_vhost_response:
            app_logger.warning("Vhost '%s' already exist.", secret.broker_vhost)
        else:
            self.rabbit_client.create_rabbit_vhost(vhost=secret.broker_vhost)

        rabbit_permissions_response = (
            self.rabbit_client.get_user_vhost_permissions(
                user=secret.broker_user, vhost=secret.broker_vhost
            )
        )
        if rabbit_permissions_response:
            app_logger.warning(
                "User '%s' already have configured permissions to vhost "
                "'%s', permission granting ignored.",
                secret.broker_user,
                secret.broker_vhost,
            )
        else:
            self.rabbit_client.create_user_vhost_permissions(
                user=secret.broker_user, vhost=secret.broker_vhost
            )
