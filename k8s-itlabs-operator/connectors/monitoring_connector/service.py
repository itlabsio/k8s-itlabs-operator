import http
import logging
from distutils.util import strtobool
from typing import Optional

from kubernetes import client, dynamic
from kubernetes.client import ApiException
from kubernetes.dynamic import ResourceList
from kubernetes.dynamic.exceptions import ResourceNotFoundError

from connectors.monitoring_connector import specifications
from connectors.monitoring_connector.dto import MonitoringConnectorMicroserviceDto

logger = logging.getLogger('servicemonitorconnector')


class KubernetesService:
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

    @staticmethod
    def get_service_monitor_api_resource() -> Optional[ResourceList]:
        api_version = "monitoring.coreos.com/v1"
        kind = "ServiceMonitor"

        crd_client = dynamic.DynamicClient(client.ApiClient())
        try:
            return crd_client.resources.get(
                api_version=api_version,
                kind=kind,
            )
        except ResourceNotFoundError:
            logger.warning(f"CRD with api_version={api_version} and kind={kind} was not found")

    @classmethod
    def create_service_monitor(cls, namespace: str, body: dict) -> bool:
        resource = cls.get_service_monitor_api_resource()
        if resource:
            resource.create(body=body, namespace=namespace)
        return bool(resource)

    @classmethod
    def delete_service_monitor(cls, namespace: str, name: str):
        resource = cls.get_service_monitor_api_resource()
        if not resource:
            return

        client_ = dynamic.DynamicClient(client.ApiClient())
        try:
            client_.delete(resource, name=name, namespace=namespace)
        except ApiException as e:
            if e.status != http.HTTPStatus.NOT_FOUND:
                logger.error(f"Couldn't delete ServiceMonitor with name={name} and namespace={namespace}: {e}")


class MonitoringConnectorService:
    @classmethod
    def create_service_monitor(cls, ms_monitoring_con: MonitoringConnectorMicroserviceDto, service_name: str,
                               namespace: str) -> bool:
        service_monitor_dict = KubernetesService.get_servicemonitor_dict(ms_monitoring_con=ms_monitoring_con,
                                                                         service_name=service_name, namespace=namespace)
        return KubernetesService.create_service_monitor(namespace=namespace, body=service_monitor_dict)

    @classmethod
    def delete_service_monitor(cls, service_name: str, namespace: str):
        KubernetesService.delete_service_monitor(namespace=namespace, name=service_name)

    @staticmethod
    def is_monitoring_connector_used_by_object(annotations: dict):
        enabled = False
        if specifications.MONITORING_ENABLED_NAME_ANNOTATION in annotations:
            enabled = bool(strtobool(annotations[specifications.MONITORING_ENABLED_NAME_ANNOTATION]))
        return enabled
