from kubernetes import client

from connectors.monitoring_connector.service import KubernetesService


class KubernetesServiceFactory:
    @classmethod
    def create_kubernetes_service(cls) -> KubernetesService:
        return KubernetesService(k8s_api_client=client.ApiClient())
