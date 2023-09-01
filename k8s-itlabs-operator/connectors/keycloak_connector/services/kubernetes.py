import abc
from abc import ABCMeta
from typing import Optional

from clients.k8s.k8s_client import KubernetesClient
from connectors.keycloak_connector.dto import KeycloakConnector
from connectors.keycloak_connector.factories.crd_factory import KeycloakConnectorCrdFactory
from connectors.keycloak_connector.factories.dto_factory import KeycloakConnectorFactory


class AbstractKubernetesService:
    __metaclass__ = ABCMeta

    @staticmethod
    def get_pod_annotations(meta: dict) -> dict:
        return meta.get("annotations", {})

    @staticmethod
    def get_pod_labels(meta: dict) -> dict:
        return meta.get("labels", {})

    @classmethod
    @abc.abstractmethod
    def get_keycloak_connector(cls, name: str) -> Optional[KeycloakConnector]:
        raise NotImplementedError


class KubernetesService(AbstractKubernetesService):
    _k8s_client = KubernetesClient

    @classmethod
    def get_keycloak_connector(cls, name: str) -> Optional[KeycloakConnector]:
        kk_connector_obj = cls._k8s_client.get_cluster_custom_object(
            group="itlabs.io",
            version="v1",
            plural="keycloakconnectors",
            name=name
        )
        if not kk_connector_obj:
            return None

        kk_connector_crd = KeycloakConnectorCrdFactory.crd_from_dict(kk_connector_obj)
        return KeycloakConnectorFactory.dto_from_kk_connector_crd(kk_connector_crd)
