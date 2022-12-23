import logging

import kopf
import sentry_sdk
from kubernetes import config
from prometheus_client import start_http_server
from sentry_sdk.integrations.aiohttp import AioHttpIntegration

from utils import logger
import settings as operator_settings
from observability.metrics.metrics import app_up
from observability.metrics.request_wrapper import wrap_request
from operators import atlasconnector, postgresconnector, rabbitconnector, monitoringconnector, sentry, \
    keycloak  # noqa: F401

if operator_settings.SENTRY_DSN:
    sentry_sdk.init(
        dsn=operator_settings.SENTRY_DSN,
        environment=operator_settings.CLUSTER_NAME,
        integrations=[
            AioHttpIntegration(),
        ],
        # Set traces_sample_rate to 1.0 to capture 100%
        # of transactions for performance monitoring.
        # We recommend adjusting this value in production.
        traces_sample_rate=1.0,
    )


@kopf.on.startup()
def configure(settings: kopf.OperatorSettings, **_):
    settings.admission.server = kopf.WebhookServer(
        cafile='/certs/ca',
        certfile='/certs/cert',
        pkeyfile='/certs/key',
        addr=operator_settings.AWH_ADDR,
        host=operator_settings.AWH_HOST,
        port=operator_settings.AWH_PORT,
    )

    try:
        settings.posting.level = logger.get_level(operator_settings.LOG_LEVEL)
    except ValueError:
        settings.posting.level = logging.INFO


try:
    wrap_request()
    app_up.labels(application='k8s-itlabs-operator').set(1)
    start_http_server(8080)
    config.load_incluster_config()
except config.ConfigException:
    try:
        config.load_kube_config(context=operator_settings.KUBERNETES_LOCAL_CONTEXT)
    except config.ConfigException:
        raise Exception("Could not configure kubernetes client")
