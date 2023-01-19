from connectors.monitoring_connector.factories.service_factories.kubernetes import KubernetesServiceFactory
from connectors.monitoring_connector.service import MonitoringConnectorService


class MonitoringConnectorServiceFactory:
    @classmethod
    def create_monitoring_connector_service(cls) -> MonitoringConnectorService:
        kubernetes_service = KubernetesServiceFactory.create_kubernetes_service()
        return MonitoringConnectorService(kubernetes_service=kubernetes_service)