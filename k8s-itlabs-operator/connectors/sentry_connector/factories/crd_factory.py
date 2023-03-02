from kubernetes.client import V1ObjectMeta

from connectors.sentry_connector.crd import SentryConnectorCrd, SentryConnectorSpec
from utils.common import deserialize_dict_to_kubeobj


class SentryConnectorCrdFactory:
    @classmethod
    def crd_from_dict(cls, crd: dict) -> SentryConnectorCrd:
        return SentryConnectorCrd(
            api_version=crd.get("apiVersion"),
            kind=crd.get("kind"),
            metadata=deserialize_dict_to_kubeobj(crd.get("metadata"), V1ObjectMeta),
            spec=cls._connector_spec_from_dict(crd.get("spec"))
        )

    @staticmethod
    def _connector_spec_from_dict(spec: dict) -> SentryConnectorSpec:
        return SentryConnectorSpec(
            url=spec.get("url"),
            token=spec.get("token"),
            organization=spec.get("organization", "sentry")
        )
