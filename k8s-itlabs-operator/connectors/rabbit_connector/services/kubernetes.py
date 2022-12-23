from clients.k8s.k8s_client import KubernetesClient
from connectors.rabbit_connector.dto import RabbitConnector
from connectors.rabbit_connector.factories.crd_factory import RabbitConnectorCrdFactory
from connectors.rabbit_connector.factories.dto_factory import RabbitConnectorFactory


class KubernetesService:
    _k8s_client = KubernetesClient

    @classmethod
    def get_rabbit_connector(cls) -> RabbitConnector:
        rabbit_con_crds_dict = cls._k8s_client.list_cluster_custom_object(
            group='itlabs.io', version='v1', plural='rabbitconnectors'
        )
        rabbit_con_crd_dto = None
        if rabbit_con_crds_dict.get('items'):
            rabbit_con_crds = [RabbitConnectorCrdFactory.crd_from_dict(crd) for crd in
                               rabbit_con_crds_dict.get('items')]
            rabbit_con_crd_dto = RabbitConnectorFactory.dto_from_rabbit_con_crds(rabbit_con_crds)
        return rabbit_con_crd_dto
