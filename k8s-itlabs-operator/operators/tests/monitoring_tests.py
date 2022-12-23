import time
from typing import Optional

import pytest
from kubernetes.client import CustomObjectsApi, ApiException, CoreV1Api, ApiClient

APP_DEPLOYMENT_NAMESPACE = "k8s-itlabs-operator"


@pytest.fixture
def app_manifest(app_name) -> dict:
    return {
        "apiVersion": "v1",
        "kind": "Service",
        "metadata": {
            "name": app_name,
            "namespace": APP_DEPLOYMENT_NAMESPACE,
            "annotations": {
                "monitoring.connector.itlabs.io/enabled": "true",
                "monitoring.connector.itlabs.io/metrics-path": "/metrics",
                "monitoring.connector.itlabs.io/interval": "15s",
            },
        },
        "spec": {
            "selector": {
                "app": app_name,
            },
            "ports": [
                {
                    "protocol": "TCP",
                    "port": 80,
                    "targetPort": 80,
                }
            ],
        },
    }


@pytest.fixture
def deploy_app(k8s, app_manifest):
    CoreV1Api(k8s).create_namespaced_service(
        namespace=app_manifest["metadata"].get("namespace"),
        body=app_manifest
    )
    yield
    CoreV1Api(k8s).delete_namespaced_service(
        name=app_manifest["metadata"].get("name"),
        namespace=app_manifest["metadata"].get("namespace")
    )


def get_service_monitor(
        k8s: ApiClient, name: str, namespace: str, timeout: int = 30
) -> Optional[object]:
    deadline = time.time() + timeout
    while time.time() <= deadline:
        try:
            return CustomObjectsApi(k8s).get_namespaced_custom_object(
                group="monitoring.coreos.com",
                version="v1",
                plural="servicemonitors",
                namespace=namespace,
                name=name,
            )
        except ApiException:
            time.sleep(5)


@pytest.mark.e2e
@pytest.mark.usefixtures("deploy_app")
def test_monitoring_was_created_on_deploy_application_with_enabled_annotations(k8s, app_manifest):
    app_name = app_manifest["metadata"].get("name")
    app_namespace = app_manifest["metadata"].get("namespace")

    service_monitor = get_service_monitor(k8s, app_name, app_namespace)
    if service_monitor is None:
        pytest.fail(
            f"Could not find ServiceMonitor by name {app_name} "
            f"in namespace {app_namespace}"
        )


@pytest.mark.e2e
@pytest.mark.usefixtures("deploy_app")
def test_monitoring_was_deleted_on_redeploy_application_with_disabled_annotations(k8s, app_manifest):
    app_name = app_manifest["metadata"].get("name")
    app_namespace = app_manifest["metadata"].get("namespace")

    # 1. Checking that ServiceMonitor has been created.
    service_monitor = get_service_monitor(k8s, app_name, app_namespace)
    if service_monitor is None:
        pytest.fail(
            f"Could not find ServiceMonitor by name {app_name} "
            f"in namespace {app_namespace}"
        )

    # 2. ServiceMonitor will be removed after being disabled.
    # app_manifest["metadata"]["annotations"]["monitoring.connector.itlabs.io/enabled"] = "false"
    # app_manifest["metadata"]["resourceVersion"] = "2"
    CoreV1Api(k8s).patch_namespaced_service(
        namespace=app_namespace,
        name=app_name,
        body={
            "metadata": {
                "annotations": {
                    "monitoring.connector.itlabs.io/enabled": "false",
                },
            },
        },
    )
    time.sleep(10)
    service_monitor = get_service_monitor(k8s, app_name, app_namespace)
    if service_monitor is not None:
        pytest.fail(
            f"ServiceMonitor was not deleted by name {app_name} "
            f"in namespace {app_namespace}"
        )


@pytest.mark.e2e
def test_monitoring_on_deleting_application(k8s, app_manifest):
    app_name = app_manifest["metadata"].get("name")
    app_namespace = app_manifest["metadata"].get("namespace")

    # 1. ServiceMonitor will be created after being deployed application.
    CoreV1Api(k8s).create_namespaced_service(
        namespace=app_namespace,
        body=app_manifest,
    )
    service_monitor = get_service_monitor(k8s, app_name, app_namespace)
    if service_monitor is None:
        pytest.fail(
            f"Could not find ServiceMonitor by name {app_name} "
            f"in namespace {app_namespace}"
        )

    # 2. ServiceMonitor will be removed after being deleted application.
    CoreV1Api(k8s).delete_namespaced_service(
        name=app_name,
        namespace=app_namespace,
    )
    time.sleep(10)
    service_monitor = get_service_monitor(k8s, app_name, app_namespace)
    if service_monitor is not None:
        pytest.fail(
            f"ServiceMonitor was not deleted by name {app_name} "
            f"in namespace {app_namespace}"
        )
