from typing import List

from connectors.rabbit_connector import specifications
from connectors.rabbit_connector.crd import RabbitConnectorCrd
from connectors.rabbit_connector.dto import RabbitConnectorMicroserviceDto, RabbitApiSecretDto, RabbitMsSecretDto, \
    RabbitConnector
from utils.passgen import generate_password


class RabbitApiSecretDtoFactory:
    @classmethod
    def dto_from_dict(cls, data: dict) -> RabbitApiSecretDto:
        return RabbitApiSecretDto(
            api_url=data.get(specifications.RABBIT_API_URL_KEY),
            api_user=data.get(specifications.RABBIT_API_USER_KEY),
            api_password=data.get(specifications.RABBIT_API_PASSWORD_KEY),
            broker_host=data.get(specifications.RABBIT_BROKER_HOST_KEY),
            broker_port=data.get(specifications.RABBIT_BROKER_PORT_KEY),
        )


class RabbitConnectorMicroserviceDtoFactory:
    @classmethod
    def dto_from_annotations(cls, annotations: dict, labels: dict) -> RabbitConnectorMicroserviceDto:
        default_name = labels.get(specifications.APP_NAME_LABEL)
        return RabbitConnectorMicroserviceDto(
            rabbit_instance_name=annotations.get(specifications.RABBIT_INSTANCE_NAME_ANNOTATION),
            vault_path=annotations.get(specifications.VAULTPATH_NAME_ANNOTATION),
            username=annotations.get(specifications.USER_NAME_ANNOTATION, default_name),
            vhost=annotations.get(specifications.VHOST_NAME_ANNOTATION, default_name)
        )


class RabbitMsSecretDtoFactory:
    @classmethod
    def dto_from_dict(cls, data: dict) -> RabbitMsSecretDto:
        return RabbitMsSecretDto(
            broker_host=data.get(specifications.RABBIT_BROKER_HOST_KEY),
            broker_port=data.get(specifications.RABBIT_BROKER_PORT_KEY),
            broker_user=data.get(specifications.RABBIT_BROKER_USER_KEY),
            broker_password=data.get(specifications.RABBIT_BROKER_PASSWORD_KEY),
            broker_vhost=data.get(specifications.RABBIT_BROKER_VHOST_KEY),
            broker_url=data.get(specifications.RABBIT_BROKER_URL_KEY),
        )

    @classmethod
    def dto_from_ms_rabbit_con(cls, rabbit_api_creds: RabbitApiSecretDto,
                               ms_rabbit_con: RabbitConnectorMicroserviceDto) -> RabbitMsSecretDto:
        password = generate_password()
        broker_url = f'amqp://{ms_rabbit_con.username}:{password}' \
                     f'@{rabbit_api_creds.broker_host}:{rabbit_api_creds.broker_port}/{ms_rabbit_con.vhost}'
        return RabbitMsSecretDto(
            broker_host=rabbit_api_creds.broker_host,
            broker_port=rabbit_api_creds.broker_port,
            broker_user=ms_rabbit_con.username,
            broker_password=password,
            broker_vhost=ms_rabbit_con.vhost,
            broker_url=broker_url
        )

    @classmethod
    def dict_from_dto(cls, rabbit_ms_creds: RabbitMsSecretDto) -> dict:
        return {
            specifications.RABBIT_BROKER_HOST_KEY: rabbit_ms_creds.broker_host,
            specifications.RABBIT_BROKER_PORT_KEY: rabbit_ms_creds.broker_port,
            specifications.RABBIT_BROKER_USER_KEY: rabbit_ms_creds.broker_user,
            specifications.RABBIT_BROKER_PASSWORD_KEY: rabbit_ms_creds.broker_password,
            specifications.RABBIT_BROKER_VHOST_KEY: rabbit_ms_creds.broker_vhost,
            specifications.RABBIT_BROKER_URL_KEY: rabbit_ms_creds.broker_url,
        }


class RabbitConnectorFactory:
    @classmethod
    def dto_from_rabbit_con_crds(cls, rabbit_con_crds: List[RabbitConnectorCrd]) -> RabbitConnector:
        rabbit_con_dto = RabbitConnector()
        for rabbit_con_crd in rabbit_con_crds:
            for spec in rabbit_con_crd.spec:
                rabbit_con_dto.add_rabbit_instance(name=spec.name, vault_path=spec.vaultpath)
        return rabbit_con_dto
