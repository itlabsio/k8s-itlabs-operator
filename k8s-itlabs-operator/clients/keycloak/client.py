import http.client
from abc import ABCMeta, abstractmethod
from typing import Optional
from urllib.parse import urljoin

import requests

from clients.keycloak.auth import BearerAuth
from clients.keycloak.dto import ClientDto, Token
from clients.keycloak.dto_factories import ClientDtoFactory, TokenDtoFactory, \
    ErrorDtoFactory
from clients.keycloak.exceptions import KeycloakError
from clients.keycloak.url_patterns import URL_ADMIN_CLIENT, URL_ADMIN_CLIENTS, \
    URL_TOKEN, URL_ADMIN_CLIENT_SECRET
from exceptions import InfrastructureServiceProblem


class AbstractKeycloakClient:
    __metaclass__ = ABCMeta

    @abstractmethod
    def get_client(self, client_id: str) -> Optional[ClientDto]:
        raise NotImplementedError

    @abstractmethod
    def create_client(self, client: ClientDto):
        raise NotImplementedError

    @abstractmethod
    def generate_secret(self, client_id: str) -> str:
        raise NotImplementedError


class KeycloakClient(AbstractKeycloakClient):
    def __init__(self, url: str, realm: str, username: str, password: str):
        self._url = url
        self._realm = realm
        self._username = username
        self._password = password

    def _build_path(self, path: str) -> str:
        return urljoin(self._url, path)

    def _get_token(self) -> Token:
        path = self._build_path(URL_TOKEN.format(realm_id=self._realm))
        try:
            response = requests.post(path, data={
                "client_id": "admin-cli",
                "grant_type": "password",
                "username": self._username,
                "password": self._password,
            })
            if response.status_code != http.client.OK:
                error = ErrorDtoFactory.dto_from_dict(response.json())
                raise InfrastructureServiceProblem("Keycloak", KeycloakError(error))
        except Exception as e:
            raise InfrastructureServiceProblem("Keycloak", e)
        return TokenDtoFactory.dto_from_dict(response.json())

    def _get_auth(self) -> BearerAuth:
        token = self._get_token()
        return BearerAuth(token.access_token)

    def get_client(self, client_id: str) -> Optional[ClientDto]:
        path = self._build_path(URL_ADMIN_CLIENT.format(
            realm_id=self._realm, client_id=client_id
        ))
        try:
            response = requests.get(path, auth=self._get_auth())
            if response.status_code != http.client.OK:
                error = ErrorDtoFactory.dto_from_dict(response.json())
                raise InfrastructureServiceProblem("Keycloak", KeycloakError(error))
            try:
                return ClientDtoFactory.dto_from_dict(response.json()[0])
            except IndexError:
                # Keycloak is return empty list if client not found. In this
                # case will be returning None.
                return
        except Exception as e:
            raise InfrastructureServiceProblem("Keycloak", e)

    def create_client(self, client: ClientDto):
        path = self._build_path(URL_ADMIN_CLIENTS.format(realm_id=self._realm))
        data = ClientDtoFactory.dict_from_dto(client)
        try:
            response = requests.post(path, auth=self._get_auth(), json=data)
            if response.status_code != http.client.CREATED:
                error = ErrorDtoFactory.dto_from_dict(response.json())
                raise InfrastructureServiceProblem("Keycloak", KeycloakError(error))
        except Exception as e:
            raise InfrastructureServiceProblem("Keycloak", e)

    def generate_secret(self, client_id: str) -> str:
        path = self._build_path(URL_ADMIN_CLIENT_SECRET.format(
            realm_id=self._realm, client_id=client_id
        ))
        try:
            response = requests.post(path, auth=self._get_auth())
            if response.status_code != http.client.OK:
                error = ErrorDtoFactory.dto_from_dict(response.json())
                raise InfrastructureServiceProblem("Keycloak", KeycloakError(error))
            return response.json().get("secret")
        except Exception as e:
            raise InfrastructureServiceProblem("Keycloak", e)
