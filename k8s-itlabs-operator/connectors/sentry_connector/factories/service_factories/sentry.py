from clients.sentry.sentryclient import SentryClient
from connectors.sentry_connector.dto import SentryApiSecretDto
from connectors.sentry_connector.services.sentry import AbstractSentryService, SentryService


class SentryServiceFactory:
    @staticmethod
    def create_sentry_service(sentry_api_cred: SentryApiSecretDto) -> AbstractSentryService:
        sentry_client = SentryClient(
            url=sentry_api_cred.api_url,
            token=sentry_api_cred.api_token,
            organization=sentry_api_cred.organization
        )
        return SentryService(sentry_client=sentry_client)
