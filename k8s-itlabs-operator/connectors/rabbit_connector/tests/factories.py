import factory
from factory import Factory

from connectors.rabbit_connector.dto import RabbitApiSecretDto, RabbitConnectorMicroserviceDto, RabbitMsSecretDto


class RabbitApiSecretDtoTestFactory(Factory):
    class Meta:
        model = RabbitApiSecretDto

    api_url = factory.Sequence(lambda n: 'api_url_%s' % n)
    api_user = factory.Sequence(lambda n: 'api_user_%s' % n)
    api_password = factory.Sequence(lambda n: 'api_password_%s' % n)
    broker_host = factory.Sequence(lambda n: 'broker_host_%s' % n)
    broker_port = factory.Sequence(lambda n: n)


class RabbitMsSecretDtoTestFactory(Factory):
    class Meta:
        model = RabbitMsSecretDto

    broker_host = factory.Sequence(lambda n: 'broker_host_%s' % n)
    broker_port = factory.Sequence(lambda n: n)
    broker_user = factory.Sequence(lambda n: 'broker_user_%s' % n)
    broker_password = factory.Sequence(lambda n: 'broker_password_%s' % n)
    broker_vhost = factory.Sequence(lambda n: 'broker_vhost_%s' % n)
    broker_url = factory.Sequence(lambda n: 'broker_url_%s' % n)


class RabbitConnectorMicroserviceDtoTestFactory(Factory):
    class Meta:
        model = RabbitConnectorMicroserviceDto

    rabbit_instance_name = factory.Sequence(lambda n: 'rabbit_instance_name_%s' % n)
    vault_path = factory.Sequence(lambda n: 'vault_path_%s' % n)
    username = factory.Sequence(lambda n: 'username_%s' % n)
    vhost = factory.Sequence(lambda n: 'vhost_%s' % n)
