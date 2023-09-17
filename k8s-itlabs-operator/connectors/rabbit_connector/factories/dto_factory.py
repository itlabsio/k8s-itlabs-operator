from connectors.rabbit_connector import specifications
from connectors.rabbit_connector.crd import RabbitConnectorCrd
from connectors.rabbit_connector.dto import RabbitConnectorMicroserviceDto, RabbitApiSecretDto, RabbitMsSecretDto, \
    RabbitConnector
from connectors.rabbit_connector.exceptions import RabbitConnectorMissingRequiredAnnotationError, \
    RabbitConnectorAnnotationEmptyValueError
from utils.passgen import generate_password
from validation.annotations_validator import AnnotationValidator


class RabbitApiSecretDtoFactory:
    @classmethod
    def api_secret_dto_from_connector(cls, rabbit_connector: RabbitConnector) -> RabbitApiSecretDto:
        return RabbitApiSecretDto(
            broker_host=rabbit_connector.broker_host,
            broker_port=rabbit_connector.broker_port,
            api_url=rabbit_connector.url,
            api_user=rabbit_connector.username,
            api_password=rabbit_connector.password,
        )


class RabbitAnnotationValidator(AnnotationValidator):
    required_annotation_names = specifications.RABBIT_CONNECTOR_REQUIRED_ANNOTATIONS
    on_missing_required_annotation_error = RabbitConnectorMissingRequiredAnnotationError
    not_empty_annotation_names = specifications.RABBIT_CONNECTOR_ANNOTATIONS
    on_empty_value_annotation_error = RabbitConnectorAnnotationEmptyValueError


class RabbitConnectorMicroserviceDtoFactory:
    @classmethod
    def dto_from_annotations(cls, annotations: dict, labels: dict) -> RabbitConnectorMicroserviceDto:
        rabbit_annotations = {}
        default_name = labels.get(specifications.APP_NAME_LABEL, "")
        for key in specifications.RABBIT_CONNECTOR_ANNOTATIONS:
            if key == specifications.USER_NAME_ANNOTATION:
                rabbit_annotations[key] = annotations.get(specifications.USER_NAME_ANNOTATION, default_name)
            elif key == specifications.VHOST_NAME_ANNOTATION:
                rabbit_annotations[key] = annotations.get(specifications.VHOST_NAME_ANNOTATION, default_name)
            elif key in annotations:
                rabbit_annotations[key] = annotations[key]
        RabbitAnnotationValidator.validate(annotations=rabbit_annotations)
        return RabbitConnectorMicroserviceDto(
            rabbit_instance_name=rabbit_annotations.get(specifications.RABBIT_INSTANCE_NAME_ANNOTATION),
            vault_path=rabbit_annotations.get(specifications.VAULTPATH_NAME_ANNOTATION),
            username=rabbit_annotations.get(specifications.USER_NAME_ANNOTATION),
            vhost=rabbit_annotations.get(specifications.VHOST_NAME_ANNOTATION),
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
    def dto_from_ms_rabbit_con(cls, rabbit_api_cred: RabbitApiSecretDto,
                               ms_rabbit_con: RabbitConnectorMicroserviceDto) -> RabbitMsSecretDto:
        password = generate_password()
        broker_url = f'amqp://{ms_rabbit_con.username}:{password}' \
                     f'@{rabbit_api_cred.broker_host}:{rabbit_api_cred.broker_port}/{ms_rabbit_con.vhost}'
        return RabbitMsSecretDto(
            broker_host=rabbit_api_cred.broker_host,
            broker_port=rabbit_api_cred.broker_port,
            broker_user=ms_rabbit_con.username,
            broker_password=password,
            broker_vhost=ms_rabbit_con.vhost,
            broker_url=broker_url
        )

    @classmethod
    def dict_from_dto(cls, rabbit_ms_cred: RabbitMsSecretDto) -> dict:
        return {
            specifications.RABBIT_BROKER_HOST_KEY: rabbit_ms_cred.broker_host,
            specifications.RABBIT_BROKER_PORT_KEY: rabbit_ms_cred.broker_port,
            specifications.RABBIT_BROKER_USER_KEY: rabbit_ms_cred.broker_user,
            specifications.RABBIT_BROKER_PASSWORD_KEY: rabbit_ms_cred.broker_password,
            specifications.RABBIT_BROKER_VHOST_KEY: rabbit_ms_cred.broker_vhost,
            specifications.RABBIT_BROKER_URL_KEY: rabbit_ms_cred.broker_url,
        }


class RabbitConnectorFactory:
    @classmethod
    def dto_from_rabbit_con_crds(cls, rabbit_con_crd: RabbitConnectorCrd) -> RabbitConnector:
        return RabbitConnector(
            broker_host=rabbit_con_crd.spec.broker_host,
            broker_port=rabbit_con_crd.spec.broker_port,
            url=rabbit_con_crd.spec.url,
            username=rabbit_con_crd.spec.username,
            password=rabbit_con_crd.spec.password,
        )
