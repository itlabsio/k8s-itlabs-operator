from typing import Optional, List

from clients.sentry.dto import SentryProject, SentryTeam, SentryProjectKey
from clients.sentry.sentryclient import AbstractSentryClient


class MockedSentryClient(AbstractSentryClient):
    def __init__(self, team: Optional[SentryTeam] = None,
                 project: Optional[SentryProject] = None,
                 project_key: Optional[SentryProjectKey] = None):
        self.team = team
        self.project = project
        self.project_key = project_key

        self.get_sentry_team_call_total = 0
        self.get_sentry_project_call_total = 0
        self.get_sentry_project_keys_call_total = 0
        self.create_sentry_team_call_total = 0
        self.create_sentry_project_call_total = 0
        self.create_sentry_project_key_call_total = 0

    def get_sentry_project(self, project_slug: str) -> Optional[SentryProject]:
        self.get_sentry_project_call_total += 1
        return self.project

    def get_sentry_team(self, team_slug: str) -> Optional[SentryTeam]:
        self.get_sentry_team_call_total += 1
        return self.team

    def get_sentry_project_keys(self, project_slug: str) -> List[SentryProjectKey]:
        self.get_sentry_project_keys_call_total += 1
        return [self.project_key]

    def create_sentry_project_key(self, project_slug: str, key_name: str) -> SentryProjectKey:
        self.create_sentry_project_key_call_total += 1
        return SentryProjectKey(name=key_name, dsn="")

    def create_sentry_team(self, team_name: str, team_slug: Optional[str]) -> SentryTeam:
        self.create_sentry_team_call_total += 1
        return SentryTeam(name=team_name, slug=team_slug)

    def create_sentry_project(self, team_slug: str, project_name: str, project_slug: Optional[str]) -> SentryProject:
        self.create_sentry_project_call_total += 1
        return SentryProject(name=project_name, slug=(project_slug or project_name))

    def delete_sentry_team(self, team_name: str):
        pass

    def delete_sentry_project(self, project_slug: str):
        pass
