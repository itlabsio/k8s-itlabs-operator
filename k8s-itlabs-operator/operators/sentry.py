import logging

import kopf

from exceptions import InfrastructureServiceProblem
from observability.metrics.decorator import monitoring
from operators.dto import ConnectorStatus
from connectors.sentry_connector.services.sentry_connector import SentryConnectorService
from connectors.sentry_connector.factories.dto_factory import SentryConnectorMicroserviceDtoFactory
from connectors.sentry_connector.factories.service_factories.sentry_connector import SentryConnectorServiceFactory
from connectors.sentry_connector.exceptions import SentryConnectorError, EnvironmentValueError
from connectors.sentry_connector.specifications import \
    SENTRY_INSTANCE_NAME_ANNOTATION


@kopf.on.mutate("pods.v1", id="sentry-connector-on-createpods")
@monitoring(connector_type='sentry_connector')
def create_pods(patch, spec, labels, annotations, **_):
    logging.info("Sentry mutate handler is called on pod creating")
    status = ConnectorStatus()
    status.is_used = SentryConnectorService.is_sentry_conn_used_by_object(annotations, labels)
    if not status.is_used:
        logging.info("Sentry connector is not used, because no expected annotations")
        return status
    try:
        ms_sentry_conn = SentryConnectorMicroserviceDtoFactory.dto_from_annotations(annotations, labels)
    except EnvironmentValueError as e:
        logging.error(e)
        status.exception = e
        return status

    sentry_conn_service = SentryConnectorServiceFactory.create_sentry_connector_service()
    logging.info("Sentry connector service is created")
    try:
        sentry_conn_service.on_create_deployment(ms_sentry_conn)
        logging.info("Sentry connector service was processed in infrastructure")
    except SentryConnectorError as e:
        status.exception = e
        status.is_enabled = False
        logging.error(e)
    except InfrastructureServiceProblem as e:
        logging.error('Problem with infrastructure, some changes may not be applied', exc_info=e)
        status.is_enabled = True
        status.exception = e
    else:
        status.is_enabled = True
        if sentry_conn_service.mutate_containers(spec, ms_sentry_conn):
            patch.spec["containers"] = spec.get("containers", [])
            patch.spec["initContainers"] = spec.get("initContainers", [])
            logging.info(f"Sentry connector service patched containers, patch.spec: {patch.spec}")
    return status


@kopf.on.create("pods.v1", id="sentry-connector-on-check-creation")
def check_creation(annotations, labels, body, spec, **_):
    if not SentryConnectorService.is_sentry_conn_used_by_object(annotations, labels):
        return None

    if not SentryConnectorService.containers_contain_required_envs(spec):
        cr_name = annotations.get(SENTRY_INSTANCE_NAME_ANNOTATION, "")
        kopf.event(
            body,
            type="Error",
            reason="SentryConnector",
            message=f"Sentry Custom Resource `{cr_name}` does not exist",
        )
