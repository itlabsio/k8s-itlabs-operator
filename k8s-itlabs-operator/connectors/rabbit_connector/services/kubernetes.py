import abc
from abc import ABCMeta
from typing import Optional

from clients.k8s.k8s_client import KubernetesClient
from connectors.rabbit_connector.dto import RabbitConnector
from connectors.rabbit_connector.factories.crd_factory import RabbitConnectorCrdFactory
from connectors.rabbit_connector.factories.dto_factory import RabbitConnectorFactory


class AbstractKubernetesService:
    __metaclass__ = ABCMeta

    @classmethod
    @abc.abstractmethod
    def get_rabbit_connector(cls, name: str) -> Optional[RabbitConnector]:
        raise NotImplementedError


class KubernetesService(AbstractKubernetesService):
    _k8s_client = KubernetesClient

    @classmethod
    def get_rabbit_connector(cls, name: str) -> Optional[RabbitConnector]:
        rabbit_conn_obj = cls._k8s_client.get_cluster_custom_object(
            group='itlabs.io',
            version='v1',
            plural='rabbitconnectors',
            name=name,
        )
        if not rabbit_conn_obj:
            return None

        rabbit_conn_crd = RabbitConnectorCrdFactory.crd_from_dict(rabbit_conn_obj)
        return RabbitConnectorFactory.dto_from_rabbit_con_crds(rabbit_conn_crd)
