import logging
from abc import ABCMeta, abstractmethod

from clients.sentry.sentryclient import AbstractSentryClient
from connectors.sentry_connector.dto import SentryMsSecretDto, SentryConnectorMicroserviceDto

app_logger = logging.getLogger("sentry_connector_sentry_service")


class AbstractSentryService:
    __metaclass__ = ABCMeta

    @abstractmethod
    def is_sentry_dsn_exist(self, project_slug: str, dsn: str) -> bool:
        raise NotImplementedError

    @abstractmethod
    def configure_sentry(self, sentry_config: SentryConnectorMicroserviceDto) -> SentryMsSecretDto:
        raise NotImplementedError


class SentryService(AbstractSentryService):
    def __init__(self, sentry_client: AbstractSentryClient) -> object:
        self.sentry_client = sentry_client

    def is_sentry_dsn_exist(self, project_slug: str, dsn: str) -> bool:
        keys = self.sentry_client.get_sentry_project_keys(project_slug)
        for k in keys:
            if k.dsn == dsn:
                return True
        return False

    def configure_sentry(self, sentry_config: SentryConnectorMicroserviceDto) -> SentryMsSecretDto:
        team = self.sentry_client.get_sentry_team(sentry_config.team)
        if not team:
            team = self.sentry_client.create_sentry_team(team_name=sentry_config.team)

        project = self.sentry_client.get_sentry_project(sentry_config.project)
        if not project:
            project = self.sentry_client.create_sentry_project(
                team_slug=team.slug, project_name=sentry_config.project
            )

        project_key = self.sentry_client.create_sentry_project_key(
            project_slug=project.slug, key_name=sentry_config.environment
        )

        return SentryMsSecretDto(project_slug=project.slug, dsn=project_key.dsn)
