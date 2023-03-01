import http
import logging
from typing import Optional

from kubernetes import client, dynamic
from kubernetes.client import ApiException
from kubernetes.dynamic import ResourceList
from kubernetes.dynamic.exceptions import ResourceNotFoundError

from connectors.monitoring_connector import specifications
from connectors.monitoring_connector.dto import MonitoringConnectorMicroserviceDto
from connectors.monitoring_connector.specifications import MONITORING_ENABLED_VALUE, MONITORING_ENABLED_LABEL_NAME
from utils.common import strtobool

logger = logging.getLogger('servicemonitorconnector')


class KubernetesService:
    def __init__(self, k8s_api_client: client.ApiClient):
        self.crd_client = dynamic.DynamicClient(k8s_api_client)
        self._sm_resource = None

    @property
    def service_monitor_api_resource(self) -> Optional[ResourceList]:
        if not self._sm_resource:
            api_version = "monitoring.coreos.com/v1"
            kind = "ServiceMonitor"
            try:
                self._sm_resource = self.crd_client.resources.get(
                    api_version=api_version,
                    kind=kind,
                )
            except ResourceNotFoundError:
                logger.warning(f"CRD with api_version={api_version} and kind={kind} was not found")
        return self._sm_resource

    @staticmethod
    def get_annotations(meta: dict) -> dict:
        return meta.get('annotations', {})

    @staticmethod
    def get_servicemonitor_dict(ms_monitoring_con: MonitoringConnectorMicroserviceDto, service_name: str,
                                namespace: str) -> dict:
        return {
            "apiVersion": "monitoring.coreos.com/v1",
            "kind": "ServiceMonitor",
            "metadata": {
                "name": service_name,
                "namespace": namespace,
                "labels": {
                    "app": "http",
                    MONITORING_ENABLED_LABEL_NAME: MONITORING_ENABLED_VALUE,
                },
            },
            "spec": {
                "jobLabel": "app",
                "selector": {
                    "matchLabels": {
                        "app": service_name,
                    },
                },
                "namespaceSelector": {
                    "matchNames": [
                        namespace,
                    ],
                },
                "endpoints": [
                    {
                        "port": "http",
                        "path": ms_monitoring_con.metric_path,
                        "interval": ms_monitoring_con.interval,
                    },
                ],
            },
        }

    def create_service_monitor(self, namespace: str, body: dict) -> bool:
        if self.service_monitor_api_resource:
            self.service_monitor_api_resource.create(body=body, namespace=namespace)
        return bool(self.service_monitor_api_resource)

    def get_service_monitor(self, namespace: str, name: str) -> Optional:
        if not self.service_monitor_api_resource:
            return
        try:
            return self.crd_client.get(
                resource=self.service_monitor_api_resource,
                name=name,
                namespace=namespace
            )
        except ApiException:
            return None

    def delete_service_monitor(self, namespace: str, name: str):
        if not self.service_monitor_api_resource:
            return
        try:
            self.crd_client.delete(self.service_monitor_api_resource, name=name, namespace=namespace)
        except ApiException as e:
            if e.status != http.HTTPStatus.NOT_FOUND:
                logger.error(f"Couldn't delete ServiceMonitor with name={name} and namespace={namespace}: {e}")


class MonitoringConnectorService:
    def __init__(self, kubernetes_service: KubernetesService):
        self.kubernetes_service = kubernetes_service

    def create_service_monitor(self, ms_monitoring_con: MonitoringConnectorMicroserviceDto, service_name: str,
                               namespace: str) -> bool:
        service_monitor_dict = self.kubernetes_service.get_servicemonitor_dict(ms_monitoring_con=ms_monitoring_con,
                                                                               service_name=service_name,
                                                                               namespace=namespace)
        return self.kubernetes_service.create_service_monitor(namespace=namespace, body=service_monitor_dict)

    def delete_service_monitor(self, namespace: str, service_name: str):
        """connector can delete only own servicemonitors"""
        sm = self.kubernetes_service.get_service_monitor(namespace=namespace, name=service_name)
        if sm is None:
            return

        labels = sm.get('metadata').get('labels')
        if labels.get(MONITORING_ENABLED_LABEL_NAME) == MONITORING_ENABLED_VALUE:
            self.kubernetes_service.delete_service_monitor(namespace=namespace, name=service_name)

    @staticmethod
    def is_monitoring_connector_used_by_object(annotations: dict):
        enabled = False
        if specifications.MONITORING_ENABLED_NAME_ANNOTATION in annotations:
            enabled = bool(strtobool(annotations[specifications.MONITORING_ENABLED_NAME_ANNOTATION]))
        return enabled
