from kubernetes.client import V1ObjectMeta

from connectors.rabbit_connector.crd import RabbitConnectorSpec, RabbitConnectorCrd
from utils.common import deserialize_dict_to_kubeobj


class RabbitConnectorCrdFactory:
    @classmethod
    def _connector_spec_from_dict(cls, spec_dict: dict) -> RabbitConnectorSpec:
        return RabbitConnectorSpec(
            name=spec_dict.get('name'),
            vaultpath=spec_dict.get('vaultpath')
        )

    @classmethod
    def crd_from_dict(cls, crd: dict) -> RabbitConnectorCrd:
        return RabbitConnectorCrd(
            api_version=crd.get('apiVersion'),
            kind=crd.get('kind'),
            metadata=deserialize_dict_to_kubeobj(crd.get('metadata'), V1ObjectMeta),
            spec=[cls._connector_spec_from_dict(spec) for spec in crd.get('spec')]
        )
