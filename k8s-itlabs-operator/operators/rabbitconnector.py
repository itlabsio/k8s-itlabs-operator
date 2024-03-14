import logging

import kopf
from connectors.rabbit_connector.exceptions import (
    RabbitConnectorCrdDoesNotExist,
    UnknownVaultPathInRabbitConnector,
)
from connectors.rabbit_connector.factories.dto_factory import (
    RabbitConnectorMicroserviceDtoFactory,
)
from connectors.rabbit_connector.factories.service_factories.rabbit_connector import (
    RabbitConnectorServiceFactory,
)
from connectors.rabbit_connector.factories.service_factories.validation import (
    RabbitConnectorValidationServiceFactory,
)
from connectors.rabbit_connector.services.rabbit_connector import (
    RabbitConnectorService,
)
from exceptions import InfrastructureServiceProblem
from observability.metrics.decorator import monitoring, mutation_hook_monitoring
from operators.dto import ConnectorStatus, MutationHookStatus
from utils.common import OwnerReferenceDto, get_owner_reference
from validation.exceptions import (
    AnnotationValidatorEmptyValueException,
    AnnotationValidatorMissedRequiredException,
)


@kopf.on.mutate("pods.v1", id="rabbit-connector-on-createpods")
@monitoring(connector_type="rabbit_connector")
def create_pods(body, patch, spec, annotations, labels, **_):
    # At the time of the creation of Pod, the name and uid were not yet
    # set in the manifest, so in the logs we refer to its owner.
    owner_ref: OwnerReferenceDto = get_owner_reference(body)
    owner_fmt = f"{owner_ref.kind}: {owner_ref.name}" if owner_ref else ""

    logging.info(
        "[%s] A rabbit mutate handler is called on pod creating" % (owner_fmt,)
    )
    status = ConnectorStatus()

    try:
        ms_rabbit_con = (
            RabbitConnectorMicroserviceDtoFactory.dto_from_annotations(
                annotations, labels
            )
        )
    except AnnotationValidatorMissedRequiredException as e:
        status.is_used = False
        logging.info(
            "[%(owner)s] Rabbit connector is not used, reason: %(error)s"
            % {"owner": owner_fmt, "error": e.message}
        )
        return status
    except AnnotationValidatorEmptyValueException as e:
        logging.error(
            "[%(owner)s] Problem with Rabbit connector: %(error)s"
            % {"owner": owner_fmt, "error": e.message},
            exc_info=e,
        )
        status.is_used = True
        status.exception = e
        return status

    rabbit_con_service = (
        RabbitConnectorServiceFactory.create_rabbit_connector_service()
    )
    logging.info("[%s] Rabbit connector service is created" % (owner_fmt,))
    try:
        rabbit_con_service.on_create_deployment(ms_rabbit_con)
        logging.info(
            "[%s] Rabbit connector service was processed in infrastructure"
            % (owner_fmt,)
        )
    except (
        RabbitConnectorCrdDoesNotExist,
        UnknownVaultPathInRabbitConnector,
    ) as e:
        logging.error(
            "[%s] Problem with Rabbit connector" % (owner_fmt,), exc_info=e
        )
        status.is_enabled = False
        status.exception = e
    except InfrastructureServiceProblem as e:
        logging.error(
            "[%s] Problem with infrastructure, some changes may not be applied"
            % (owner_fmt,),
            exc_info=e,
        )
        status.is_enabled = True
        status.exception = e
    else:
        status.is_enabled = True
        if rabbit_con_service.mutate_containers(spec, ms_rabbit_con):
            patch.spec["containers"] = spec.get("containers", [])
            patch.spec["initContainers"] = spec.get("initContainers", [])
            logging.info(
                "[%(owner)s] Rabbit connector service patched containers, "
                "patch.spec: %(spec)s"
                % {"owner": owner_fmt, "spec": patch.spec}
            )
    return status


@kopf.on.create("pods.v1", id="rabbit-connector-on-check-creation")
@mutation_hook_monitoring(connector_type="rabbit_connector")
def check_creation(annotations, name, labels, body, **_):
    status = MutationHookStatus()
    try:
        ms_rabbit_con = (
            RabbitConnectorMicroserviceDtoFactory.dto_from_annotations(
                annotations, labels
            )
        )
    except AnnotationValidatorMissedRequiredException as e:
        status.is_used = False
        logging.info(
            "[%(name)s] Rabbit connector is not used, reason: %(error)s"
            % {"name": name, "error": e.message}
        )
        return status
    except AnnotationValidatorEmptyValueException as e:
        logging.error(
            "[%(name)s] Problem with Rabbit connector: %(error)s"
            % {"name": name, "error": e.message},
            exc_info=e,
        )
        status.is_used = True
        status.exception = e
        return status

    status.is_used = True
    status.is_success = True

    owner = get_owner_reference(body)
    status.owner = f"{owner.kind}: {owner.name}" if owner else ""

    spec = body.get("spec", {})
    if not RabbitConnectorService.any_containers_contain_required_envs(spec):
        status.is_success = False

        service = RabbitConnectorValidationServiceFactory.create()
        error_msg = (
            "Rabbit Connector not applied by unknown reasons. "
            "It's maybe problems with infrastructure or certificates."
        )
        if errors := service.validate(ms_rabbit_con):
            reasons = "; ".join(str(e) for e in errors)
            error_msg = (
                f"Rabbit Connector not applied for next reasons: {reasons}"
            )

        kopf.event(
            body,
            type="Error",
            reason="RabbitConnector",
            message=error_msg,
        )

    return status
