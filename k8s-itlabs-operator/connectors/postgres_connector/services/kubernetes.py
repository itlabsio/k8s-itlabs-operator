import logging
from typing import Optional

from clients.k8s.k8s_client import KubernetesClient
from connectors.postgres_connector.dto import PgConnector
from connectors.postgres_connector.factories.crd_factory import PostgresConnectorCrdFactory
from connectors.postgres_connector.factories.dto_factory import PgConnectorFactory

logger = logging.getLogger('PgConnectorK8sService')


class KubernetesService:
    _k8s_client = KubernetesClient

    @classmethod
    def get_pg_connector(cls) -> Optional[PgConnector]:
        pg_con_crds_dict = cls._k8s_client.list_cluster_custom_object(
            group='itlabs.io', version='v1', plural='postgresconnectors'
        )
        pg_con_crd_dto = None
        if pg_con_crds_dict.get('items'):
            pg_con_crds = [PostgresConnectorCrdFactory.crd_from_dict(crd) for crd in pg_con_crds_dict.get('items')]
            pg_con_crd_dto = PgConnectorFactory.dto_from_pg_con_crds(pg_con_crds)
        return pg_con_crd_dto
