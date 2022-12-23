from typing import Optional

from clients.k8s.k8s_client import KubernetesClient
from connectors.sentry_connector.dto import SentryConnector
from connectors.sentry_connector.factories.crd_factory import SentryConnectorCrdFactory
from connectors.sentry_connector.factories.dto_factory import SentryConnectorFactory


class KubernetesService:
    _k8s_client = KubernetesClient

    @staticmethod
    def get_pod_annotations(meta: dict) -> dict:
        return meta.get("annotations", {})

    @staticmethod
    def get_pod_labels(meta: dict) -> dict:
        return meta.get("labels", {})

    @classmethod
    def get_sentry_connector(cls, name: str) -> Optional[SentryConnector]:
        sentry_connector_obj = cls._k8s_client.get_cluster_custom_object(
            group="itlabs.io", version="v1", plural="sentryconnectors", name=name
        )
        if not sentry_connector_obj:
            return

        sentry_connector_crd = SentryConnectorCrdFactory.crd_from_dict(sentry_connector_obj)
        return SentryConnectorFactory.dto_from_sentry_connector_crd(sentry_connector_crd)
