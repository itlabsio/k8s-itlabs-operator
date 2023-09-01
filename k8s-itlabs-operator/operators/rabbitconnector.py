import logging

import kopf

from exceptions import InfrastructureServiceProblem
from observability.metrics.decorator import monitoring, mutation_hook_monitoring
from operators.dto import ConnectorStatus, MutationHookStatus
from connectors.rabbit_connector.exceptions import RabbitConnectorCrdDoesNotExist, UnknownVaultPathInRabbitConnector
from connectors.rabbit_connector.factories.dto_factory import RabbitConnectorMicroserviceDtoFactory
from connectors.rabbit_connector.factories.service_factories.rabbit_connector import RabbitConnectorServiceFactory
from connectors.rabbit_connector.services.rabbit_connector import RabbitConnectorService
from connectors.rabbit_connector.factories.service_factories.validation import \
    RabbitConnectorValidationServiceFactory
from utils.common import OwnerReferenceDto, get_owner_reference


@kopf.on.mutate('pods.v1', id='rabbit-connector-on-createpods')
@monitoring(connector_type='rabbit_connector')
def create_pods(body, patch, spec, annotations, labels, **_):
    # At the time of the creation of Pod, the name and uid were not yet
    # set in the manifest, so in the logs we refer to its owner.
    owner_ref: OwnerReferenceDto = get_owner_reference(body)
    owner_fmt = f"{owner_ref.kind}: {owner_ref.name}" if owner_ref else ""

    logging.info(f"[{owner_fmt}] A rabbit mutate handler is called on pod creating")
    status = ConnectorStatus()
    status.is_used = RabbitConnectorService.is_rabbit_conn_used_by_object(annotations)
    if not status.is_used:
        logging.info(f"[{owner_fmt}] Rabbit connector is not used, because no expected annotations")
        return status
    ms_rabbit_con = RabbitConnectorMicroserviceDtoFactory.dto_from_annotations(annotations, labels)
    rabbit_con_service = RabbitConnectorServiceFactory.create_rabbit_connector_service()
    logging.info(f"[{owner_fmt}] Rabbit connector service is created")
    try:
        rabbit_con_service.on_create_deployment(ms_rabbit_con)
        logging.info(f"[{owner_fmt}] Rabbit connector service was processed in infrastructure")
    except (RabbitConnectorCrdDoesNotExist, UnknownVaultPathInRabbitConnector) as e:
        logging.error(f"[{owner_fmt}] Problem with Rabbit connector", exc_info=e)
        status.is_enabled = False
        status.exception = e
    except InfrastructureServiceProblem as e:
        logging.error(f'[{owner_fmt}] Problem with infrastructure, some changes may not be applied', exc_info=e)
        status.is_enabled = True
        status.exception = e
    else:
        status.is_enabled = True
        if rabbit_con_service.mutate_containers(spec, ms_rabbit_con):
            patch.spec['containers'] = spec.get('containers', [])
            patch.spec['initContainers'] = spec.get('initContainers', [])
            logging.info(f"[{owner_fmt}] Rabbit connector service patched containers, patch.spec: {patch.spec}")
    return status


@kopf.on.create("pods.v1", id="rabbit-connector-on-check-creation")
@mutation_hook_monitoring(connector_type="rabbit_connector")
def check_creation(annotations, labels, body, **_):
    status = MutationHookStatus()

    if not RabbitConnectorService.is_rabbit_conn_used_by_object(annotations):
        status.is_used = False
        return status

    status.is_used = True
    status.is_success = True
    spec = body.get("spec", {})
    if not RabbitConnectorService.any_containers_contain_required_envs(spec):
        status.is_success = False

        connector_dto = RabbitConnectorMicroserviceDtoFactory.dto_from_annotations(annotations, labels)
        service = RabbitConnectorValidationServiceFactory.create()
        errors = service.validate(connector_dto)
        if errors:
            reasons = "; ".join(str(e) for e in errors)
            kopf.event(
                body,
                type="Error",
                reason="RabbitConnector",
                message=f"Rabbit Connector not applied for next reasons: {reasons}",
            )
        else:
            kopf.event(
                body,
                type="Error",
                reason="RabbitConnector",
                message=(
                    "Rabbit Connector not applied by unknown reasons. "
                    "It's maybe problems with infrastructure or certificates."
                )
            )

    return status
