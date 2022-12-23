import factory
from factory import Factory

from clients.postgres.dto import PgConnectorDbSecretDto


class PgConnectorDbSecretDtoTestFactory(Factory):
    class Meta:
        model = PgConnectorDbSecretDto

    db_name = factory.Sequence(lambda n: 'db_name_%s' % n)
    user = factory.Sequence(lambda n: 'user_%s' % n)
    password = factory.Sequence(lambda n: 'password_%s' % n)
    host = factory.Sequence(lambda n: 'host_%s' % n)
    port = factory.Sequence(lambda n: n + 1)
