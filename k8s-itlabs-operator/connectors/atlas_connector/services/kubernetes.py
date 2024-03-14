import settings
from clients.k8s.k8s_client import KubernetesClient
from connectors.atlas_connector import specifications
from connectors.atlas_connector.dto import AtlasConfigDto
from connectors.atlas_connector.factories.dto_factory import (
    AtlasConfigDtoFactory,
)


class KubernetesService:
    _k8s_client = KubernetesClient

    @classmethod
    def get_atlas_config(cls) -> AtlasConfigDto:
        configmap_data = cls._k8s_client.get_configmap_data(
            name=specifications.CONFIGMAP_NAME,
            namespace=settings.OPERATOR_NAMESPACE,
        )
        return AtlasConfigDtoFactory.dto_from_dict(
            configmap_data=configmap_data
        )
