import logging

import kopf

from exceptions import InfrastructureServiceProblem
from observability.metrics.decorator import monitoring
from operators.dto import ConnectorStatus
from connectors.rabbit_connector.exceptions import RabbitConnectorCrdDoesNotExist, UnknownVaultPathInRabbitConnector
from connectors.rabbit_connector.factories.dto_factory import RabbitConnectorMicroserviceDtoFactory
from connectors.rabbit_connector.factories.service_factories.rabbit_connector import RabbitConnectorServiceFactory
from connectors.rabbit_connector.services.rabbit_connector import RabbitConnectorService
from connectors.rabbit_connector.specifications import \
    RABBIT_INSTANCE_NAME_ANNOTATION


@kopf.on.mutate('pods.v1', id='rabbit-connector-on-createpods')
@monitoring(connector_type='rabbit_connector')
def create_pods(patch, spec, annotations, labels, body, **kwargs):
    logging.info("A rabbit mutate handler is called on pod creating")
    status = ConnectorStatus()
    status.is_used = RabbitConnectorService.is_rabbit_conn_used_by_object(annotations)
    if not status.is_used:
        logging.info("Rabbit connector is not used, because no expected annotations")
        return status
    ms_rabbit_con = RabbitConnectorMicroserviceDtoFactory.dto_from_annotations(annotations, labels)
    rabbit_con_service = RabbitConnectorServiceFactory.create_rabbit_connector_service()
    logging.info("Rabbit connector service is created")
    try:
        rabbit_con_service.on_create_deployment(ms_rabbit_con)
        logging.info("Rabbit connector service was processed in infrastructure")
    except (RabbitConnectorCrdDoesNotExist, UnknownVaultPathInRabbitConnector):
        status.is_enabled = False
    except InfrastructureServiceProblem as e:
        logging.error('Problem with infrastructure, some changes may not be applied', exc_info=e)
        status.is_enabled = True
        status.exception = e
    else:
        status.is_enabled = True
        if rabbit_con_service.mutate_containers(spec, ms_rabbit_con):
            patch.spec['containers'] = spec.get('containers', [])
            patch.spec['initContainers'] = spec.get('initContainers', [])
            logging.info(f"Rabbit connector service patched containers, patch.spec: {patch.spec}")
    return status


@kopf.on.create("pods.v1", id="rabbit-connector-on-check-creation")
def check_creation(annotations, body, spec, **_):
    if not RabbitConnectorService.is_rabbit_conn_used_by_object(annotations):
        return None

    if not RabbitConnectorService.containers_contain_required_envs(spec):
        cr_name = annotations.get(RABBIT_INSTANCE_NAME_ANNOTATION, "")
        kopf.event(
            body,
            type="Error",
            reason="RabbitConnector",
            message=f"Rabbit Custom Resource `{cr_name}` does not exist",
        )
