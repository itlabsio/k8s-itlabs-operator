import logging

import kopf
from connectors.sentry_connector.exceptions import SentryConnectorError
from connectors.sentry_connector.factories.dto_factory import (
    SentryConnectorMicroserviceDtoFactory,
)
from connectors.sentry_connector.factories.service_factories.sentry_connector import (
    SentryConnectorServiceFactory,
)
from connectors.sentry_connector.factories.service_factories.validation import (
    SentryConnectorValidationServiceFactory,
)
from connectors.sentry_connector.services.sentry_connector import (
    SentryConnectorService,
)
from exceptions import InfrastructureServiceProblem
from observability.metrics.decorator import monitoring, mutation_hook_monitoring
from operators.dto import ConnectorStatus, MutationHookStatus
from utils.common import OwnerReferenceDto, get_owner_reference
from validation.exceptions import (
    AnnotationValidatorEmptyValueException,
    AnnotationValidatorMissedRequiredException,
)


@kopf.on.mutate("pods.v1", id="sentry-connector-on-createpods")
@monitoring(connector_type="sentry_connector")
def create_pods(body, patch, spec, labels, annotations, **_):
    # At the time of the creation of Pod, the name and uid were not yet
    # set in the manifest, so in the logs we refer to its owner.
    owner_ref: OwnerReferenceDto = get_owner_reference(body)
    owner_fmt = f"{owner_ref.kind}: {owner_ref.name}" if owner_ref else ""

    logging.info(
        "[%s] Sentry mutate handler is called on pod creating", owner_fmt
    )
    status = ConnectorStatus()
    try:
        ms_sentry_conn = (
            SentryConnectorMicroserviceDtoFactory.dto_from_annotations(
                annotations, labels
            )
        )
    except AnnotationValidatorMissedRequiredException as e:
        status.is_used = False
        logging.info(
            "[%s] Sentry connector is not used, reason: %s",
            owner_fmt,
            e.message,
        )
        return status
    except AnnotationValidatorEmptyValueException as e:
        logging.error(
            "[%s] Problem with Sentry connector: %s",
            owner_fmt,
            e.message,
            exc_info=e,
        )
        status.is_used = True
        status.exception = e
        return status

    sentry_conn_service = (
        SentryConnectorServiceFactory.create_sentry_connector_service()
    )
    logging.info("[%s] Sentry connector service is created", owner_fmt)
    try:
        sentry_conn_service.on_create_deployment(ms_sentry_conn)
        logging.info(
            "[%s] Sentry connector service was processed in infrastructure",
            owner_fmt,
        )
    except SentryConnectorError as e:
        logging.error(
            "[%s] Problem with Sentry connector", owner_fmt, exc_info=e
        )
        status.is_enabled = False
        status.exception = e
    except InfrastructureServiceProblem as e:
        logging.error(
            "[%s] Problem with infrastructure, some changes may not be applied",
            owner_fmt,
            exc_info=e,
        )
        status.is_enabled = True
        status.exception = e
    else:
        status.is_enabled = True
        if sentry_conn_service.mutate_containers(spec, ms_sentry_conn):
            patch.spec["containers"] = spec.get("containers", [])
            patch.spec["initContainers"] = spec.get("initContainers", [])
            logging.info(
                "[%s] Sentry connector service patched containers, patch.spec: %s",
                owner_fmt,
                patch.spec,
            )
    return status


@kopf.on.create("pods.v1", id="sentry-connector-on-check-creation")
@mutation_hook_monitoring(connector_type="sentry_connector")
def check_creation(annotations, name, labels, body, **_):
    status = MutationHookStatus()
    try:
        ms_sentry_conn = (
            SentryConnectorMicroserviceDtoFactory.dto_from_annotations(
                annotations, labels
            )
        )
    except AnnotationValidatorMissedRequiredException as e:
        status.is_used = False
        logging.info(
            "[%s] Sentry connector is not used, reason: %s", name, e.message
        )
        return status
    except AnnotationValidatorEmptyValueException as e:
        logging.error(
            "[%s] Problem with Sentry connector: %s",
            name,
            e.message,
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
    if not SentryConnectorService.any_containers_contain_required_envs(spec):
        status.is_success = False

        service = SentryConnectorValidationServiceFactory.create()
        error_msg = (
            "Sentry Connector not applied by unknown reasons. "
            "It's maybe problems with infrastructure or certificates."
        )
        if errors := service.validate(ms_sentry_conn):
            reasons = "; ".join(str(e) for e in errors)
            error_msg = (
                f"Sentry Connector not applied for next reasons: {reasons}"
            )

        kopf.event(
            body,
            type="Error",
            reason="SentryConnector",
            message=error_msg,
        )

    return status
