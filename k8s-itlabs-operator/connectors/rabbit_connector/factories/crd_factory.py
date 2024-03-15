from connectors.rabbit_connector.crd import (
    RabbitConnectorCrd,
    RabbitConnectorSpec,
)
from kubernetes.client import V1ObjectMeta
from utils.common import deserialize_dict_to_kubeobj


class RabbitConnectorCrdFactory:
    @classmethod
    def _connector_spec_from_dict(cls, spec: dict) -> RabbitConnectorSpec:
        return RabbitConnectorSpec(
            broker_host=spec.get("brokerHost"),
            broker_port=spec.get("brokerPort", 5672),
            url=spec.get("url"),
            username=spec.get("username"),
            password=spec.get("password"),
        )

    @classmethod
    def crd_from_dict(cls, crd: dict) -> RabbitConnectorCrd:
        return RabbitConnectorCrd(
            api_version=crd.get("apiVersion"),
            kind=crd.get("kind"),
            metadata=deserialize_dict_to_kubeobj(
                crd.get("metadata"), V1ObjectMeta
            ),
            spec=cls._connector_spec_from_dict(crd.get("spec")),
        )
