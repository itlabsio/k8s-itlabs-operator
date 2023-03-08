from typing import Dict, Optional

from kubernetes import client, config
from kubernetes.client import V1ConfigMap, ApiException

import settings as operator_settings


class KubernetesClient:
    @staticmethod
    def get_configmap_data(name: str, namespace: str) -> dict:
        config_map: V1ConfigMap = client.CoreV1Api().read_namespaced_config_map(name=name, namespace=namespace)
        return config_map.data

    @staticmethod
    def get_cluster_custom_object(group: str, version: str, plural: str, name: str) -> Optional[Dict]:
        api = client.CustomObjectsApi()
        try:
            return api.get_cluster_custom_object(
                group=group,
                version=version,
                plural=plural,
                name=name
            )
        except ApiException:
            return None

    @staticmethod
    def configure_kubernetes():
        try:
            config.load_incluster_config()
        except config.ConfigException:
            try:
                config.load_kube_config(context=operator_settings.KUBERNETES_LOCAL_CONTEXT)
            except config.ConfigException as e:
                raise config.ConfigException("Could not configure kubernetes client") from e
