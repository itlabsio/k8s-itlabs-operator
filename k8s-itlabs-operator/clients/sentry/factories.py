from clients.sentry.sentryclient import AbstractSentryClient, SentryClient
from clients.sentry.settings import SENTRY_ORGANIZATION, SENTRY_TOKEN


class SentryClientFactory:
    @staticmethod
    def create_sentry_client(sentry_url: str) -> AbstractSentryClient:
        return SentryClient(
            url=sentry_url, token=SENTRY_TOKEN, organization=SENTRY_ORGANIZATION
        )
