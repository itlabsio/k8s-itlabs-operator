from abc import ABCMeta, abstractmethod
from typing import Optional, List
from http import HTTPStatus
import requests
import ujson

from exceptions import InfrastructureServiceProblem
from utils.common import join
from clients.sentry.settings import SENTRY_TIMEOUT
from clients.sentry.exceptions import SentryClientError
from clients.sentry.dto import SentryTeam, SentryProject, SentryProjectKey
from clients.sentry.dto_factories import SentryTeamDtoFactory, SentryProjectDtoFactory, SentryProjectKeyDtoFactory


class AbstractSentryClient:
    __metaclass__ = ABCMeta

    @abstractmethod
    def get_sentry_team(self, team_slug: str) -> Optional[SentryTeam]:
        raise NotImplementedError

    @abstractmethod
    def create_sentry_team(self, team_name: str, team_slug: Optional[str] = None) -> SentryTeam:
        raise NotImplementedError

    @abstractmethod
    def delete_sentry_team(self, team_name: str):
        raise NotImplementedError

    @abstractmethod
    def get_sentry_project(self, project_slug: str) -> Optional[SentryProject]:
        raise NotImplementedError

    @abstractmethod
    def create_sentry_project(self, team_slug: str, project_name: str,
                              project_slug: Optional[str] = None) -> SentryProject:
        raise NotImplementedError

    @abstractmethod
    def delete_sentry_project(self, project_slug: str):
        raise NotImplementedError

    @abstractmethod
    def get_sentry_project_keys(self, project_slug: str) -> List[SentryProjectKey]:
        raise NotImplementedError

    @abstractmethod
    def create_sentry_project_key(self, project_slug: str, key_name: str) -> SentryProjectKey:
        raise NotImplementedError


class SentryClient(AbstractSentryClient):
    def __init__(self, url: str, token: str, organization: str):
        self.url = url
        self.token = token
        self.organization = organization

    def _send_request(self, endpoint: str, data: Optional[dict] = None, method: str = "GET"):
        endpoint = join(self.url, f'/api/0{endpoint}')
        headers = {
            'Authorization': "Bearer " + self.token,
            "content-type": "application/json"
        }
        try:
            response = requests.request(
                method=method,
                url=endpoint,
                headers=headers,
                data=ujson.dumps(data),
                timeout=SENTRY_TIMEOUT
            )

            if response.ok:
                if response.status_code == HTTPStatus.NO_CONTENT:
                    return None
                return response.json()

            if response.status_code == HTTPStatus.NOT_FOUND:
                return None

            raise InfrastructureServiceProblem('Sentry', SentryClientError(response))
        except Exception as e:
            raise InfrastructureServiceProblem('Sentry', e)

    def get_sentry_team(self, team_slug: str) -> Optional[SentryTeam]:
        response = self._send_request(endpoint=f"/teams/{self.organization}/{team_slug}/")
        if response:
            return SentryTeamDtoFactory.dto_from_dict(response)
        return None

    def create_sentry_team(self, team_name: str, team_slug: Optional[str] = None) -> SentryTeam:
        data = SentryTeamDtoFactory.dict_from_dto(SentryTeam(name=team_name, slug=team_slug))
        response = self._send_request(endpoint=f"/organizations/{self.organization}/teams/", method="POST", data=data)
        return SentryTeamDtoFactory.dto_from_dict(response)

    def delete_sentry_team(self, team_name: str):
        self._send_request(endpoint=f"/teams/{self.organization}/{team_name}/", method="DELETE")

    def get_sentry_project(self, project_slug: str) -> Optional[SentryProject]:
        response = self._send_request(endpoint=f"/projects/{self.organization}/{project_slug}/")
        if response:
            return SentryProjectDtoFactory.dto_from_dict(response)
        return None

    def create_sentry_project(self, team_slug: str, project_name: str,
                              project_slug: Optional[str] = None) -> SentryProject:
        data = SentryProjectDtoFactory.dict_from_dto(SentryProject(name=project_name, slug=project_slug))
        response = self._send_request(endpoint=f"/teams/{self.organization}/{team_slug}/projects/", method="POST",
                                      data=data)
        return SentryProjectDtoFactory.dto_from_dict(response)

    def delete_sentry_project(self, project_slug: str):
        self._send_request(endpoint=f"/projects/{self.organization}/{project_slug}/", method="DELETE")

    def get_sentry_project_keys(self, project_slug: str) -> List[SentryProjectKey]:
        response = self._send_request(endpoint=f"/projects/{self.organization}/{project_slug}/keys/")
        return [SentryProjectKeyDtoFactory.dto_from_dict(r) for r in response] if response else []

    def create_sentry_project_key(self, project_slug: str, key_name: str) -> SentryProjectKey:
        data = {"name": key_name}
        response = self._send_request(endpoint=f"/projects/{self.organization}/{project_slug}/keys/",
                                      method="POST", data=data)
        return SentryProjectKeyDtoFactory.dto_from_dict(response)
