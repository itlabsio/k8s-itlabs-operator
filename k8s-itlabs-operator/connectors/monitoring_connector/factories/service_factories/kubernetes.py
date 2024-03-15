from connectors.monitoring_connector.service import KubernetesService
from kubernetes import client


class KubernetesServiceFactory:
    @classmethod
    def create_kubernetes_service(cls) -> KubernetesService:
        return KubernetesService(k8s_api_client=client.ApiClient())
