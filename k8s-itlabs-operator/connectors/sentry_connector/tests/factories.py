import factory
from factory import Factory

from connectors.sentry_connector.dto import SentryConnectorMicroserviceDto


class SentryConnectorMicroserviceDtoTestFactory(Factory):
    class Meta:
        model = SentryConnectorMicroserviceDto

    sentry_instance_name = factory.Sequence(lambda n: "sentry_instance_name_%s" % n)
    vault_path = factory.Sequence(lambda n: "vault_path_%s" % n)
    project = factory.Sequence(lambda n: "project_%s" % n)
    team = factory.Sequence(lambda n: "team_%s" % n)
    environment = factory.Sequence(lambda n: "environment_%s" % n)
