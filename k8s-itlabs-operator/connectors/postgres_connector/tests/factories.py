import factory
from factory import Factory

from connectors.postgres_connector.dto import PgConnectorInstanceSecretDto, PgConnectorMicroserviceDto


class PgConnectorInstanceSecretDtoTestFactory(Factory):
    class Meta:
        model = PgConnectorInstanceSecretDto

    db_name = factory.Sequence(lambda n: 'db_name_%s' % n)
    user = factory.Sequence(lambda n: 'user_%s' % n)
    password = factory.Sequence(lambda n: 'password_%s' % n)
    host = factory.Sequence(lambda n: 'host_%s' % n)
    port = factory.Sequence(lambda n: n + 1)
    db_kube_domain = factory.Sequence(lambda n: 'db_kube_domain_%s' % n)


class PgConnectorMicroserviceDtoTestFactory(Factory):
    class Meta:
        model = PgConnectorMicroserviceDto

    pg_instance_name = factory.Sequence(lambda n: 'pg_instance_name_%s' % n)
    vault_path = factory.Sequence(lambda n: 'vault_path_%s' % n)
    db_name = factory.Sequence(lambda n: 'db_name_%s' % n)
    db_username = factory.Sequence(lambda n: 'db_username_%s' % n)
