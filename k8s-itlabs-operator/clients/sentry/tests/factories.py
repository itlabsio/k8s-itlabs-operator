import factory
from factory import Factory

from clients.sentry.dto import SentryTeam, SentryProject, SentryProjectKey


class SentryTeamTestFactory(Factory):
    class Meta:
        model = SentryTeam

    name = factory.Sequence(lambda n: "name_%s" % n)
    slug = factory.Sequence(lambda n: "slug_%s" % n)


class SentryProjectTestFactory(Factory):
    class Meta:
        model = SentryProject

    name = factory.Sequence(lambda n: "name_%s" % n)
    slug = factory.Sequence(lambda n: "slug_%s" % n)


class SentryProjectKeyTestFactory(Factory):
    class Meta:
        model = SentryProjectKey

    name = factory.Sequence(lambda n: "name_%s" % n)
    dsn = factory.Sequence(lambda n: "dsn_%s" % n)
