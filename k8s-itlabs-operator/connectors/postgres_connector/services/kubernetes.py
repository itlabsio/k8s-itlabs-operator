import abc
import logging
from abc import ABCMeta
from typing import Optional

from clients.k8s.k8s_client import KubernetesClient
from connectors.postgres_connector.dto import PgConnector
from connectors.postgres_connector.factories.crd_factory import (
    PostgresConnectorCrdFactory,
)
from connectors.postgres_connector.factories.dto_factory import (
    PgConnectorFactory,
)

logger = logging.getLogger("PgConnectorK8sService")


class AbstractKubernetesService:
    __metaclass__ = ABCMeta

    @classmethod
    @abc.abstractmethod
    def get_pg_connector(cls, name: str) -> Optional[PgConnector]:
        raise NotImplementedError


class KubernetesService(AbstractKubernetesService):
    _k8s_client = KubernetesClient

    @classmethod
    def get_pg_connector(cls, name: str) -> Optional[PgConnector]:
        pg_conn_obj = cls._k8s_client.get_cluster_custom_object(
            group="itlabs.io",
            version="v1",
            plural="postgresconnectors",
            name=name,
        )
        if not pg_conn_obj:
            return None

        pg_conn_crd = PostgresConnectorCrdFactory.crd_from_dict(pg_conn_obj)
        return PgConnectorFactory.dto_from_pg_con_crds(pg_conn_crd)
