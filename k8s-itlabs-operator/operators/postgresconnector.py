import logging

import kopf
from connectors.postgres_connector.exceptions import (
    PgConnectorAnnotationEmptyValueError,
    PgConnectorCrdDoesNotExist,
    PgConnectorMissingRequiredAnnotationError,
    UnknownVaultPathInPgConnector,
)
from connectors.postgres_connector.factories.dto_factory import (
    PgConnectorMicroserviceDtoFactory,
)
from connectors.postgres_connector.factories.service_factories.postgres_connector import (
    PostgresConnectorServiceFactory,
)
from connectors.postgres_connector.factories.service_factories.validation import (
    PostgresConnectorValidationServiceFactory,
)
from connectors.postgres_connector.services.postgres_connector import (
    PostgresConnectorService,
)
from exceptions import InfrastructureServiceProblem
from observability.metrics.decorator import monitoring, mutation_hook_monitoring
from operators.dto import ConnectorStatus, MutationHookStatus
from utils.common import OwnerReferenceDto, get_owner_reference


@kopf.on.create("postgresconnectors")
def create_fn(body, **_):
    logging.info(f"A handler is called with body: {body}")


@kopf.on.mutate("pods.v1", id="pg-con-on-createpods")
@monitoring(connector_type="postgres_connector")
def create_pods(body, patch, spec, annotations, labels, **_):
    # At the time of the creation of Pod, the name and uid were not yet
    # set in the manifest, so in the logs we refer to its owner.
    owner_ref: OwnerReferenceDto = get_owner_reference(body)
    owner_fmt = f"{owner_ref.kind}: {owner_ref.name}" if owner_ref else ""

    logging.info(
        "[%s] A postgres mutate handler is called on pod creating", owner_fmt
    )
    status = ConnectorStatus()
    try:
        ms_pg_con = PgConnectorMicroserviceDtoFactory.dto_from_annotations(
            annotations, labels
        )
    except PgConnectorMissingRequiredAnnotationError as e:
        status.is_used = False
        logging.info(
            "[%s] Postgres connector is not used, reason: %s",
            owner_fmt,
            e.message,
        )
        return status
    except PgConnectorAnnotationEmptyValueError as e:
        logging.error(
            "[%s] Problem with Rabbit connector: %s",
            owner_fmt,
            e.message,
            exc_info=e,
        )
        status.is_enabled = False
        status.is_used = False
        return status

    pg_con_service = (
        PostgresConnectorServiceFactory.create_postgres_connector_service()
    )
    logging.info("[%s] Postgres connector service is created", owner_fmt)
    try:
        pg_con_service.on_create_deployment(ms_pg_con)
        logging.info(
            "[%s] Postgres connector service was processed in infrastructure",
            owner_fmt,
        )
    except (PgConnectorCrdDoesNotExist, UnknownVaultPathInPgConnector) as e:
        logging.error(
            "[%s] Problem with Postgres connector", owner_fmt, exc_info=e
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
        if pg_con_service.mutate_containers(spec, ms_pg_con):
            patch.spec["containers"] = spec.get("containers", [])
            patch.spec["initContainers"] = spec.get("initContainers", [])
            logging.info(
                "[%s] Postgres connector service patched containers, patch.spec: %s",
                owner_fmt,
                patch.spec,
            )
    return status


@kopf.on.create("pods.v1", id="postgres-connector-on-check-creation")
@mutation_hook_monitoring(connector_type="postgres_connector")
def check_creation(annotations, name, labels, body, **_):
    status = MutationHookStatus()
    try:
        connector_dto = PgConnectorMicroserviceDtoFactory.dto_from_annotations(
            annotations, labels
        )
    except PgConnectorMissingRequiredAnnotationError:
        status.is_used = False
        return status
    except PgConnectorAnnotationEmptyValueError as e:
        logging.error(
            "[%s] Problem with Postgres connector: %s",
            name,
            e.message,
            exc_info=e,
        )
        status.is_enabled = False
        status.exception = e
        return status

    status.is_used = True
    status.is_success = True

    spec = body.get("spec", {})
    owner = get_owner_reference(body)
    status.owner = f"{owner.kind}: {owner.name}" if owner else ""

    is_contain_required_envs = (
        PostgresConnectorService.any_containers_contain_required_envs(spec)
    )

    if connector_dto and (
        not is_contain_required_envs
        or connector_dto.grant_access_for_readonly_user
    ):
        service = PostgresConnectorValidationServiceFactory.create()
        error_msg = (
            (
                "Postgres Connector not applied by unknown reasons. "
                "It's maybe problems with infrastructure or certificates."
            )
            if not is_contain_required_envs
            else ""
        )
        if errors := service.validate(connector_dto):
            reasons = "; ".join(str(e) for e in errors)
            error_msg = (
                f"Postgres Connector not applied for next reasons: {reasons}"
            )
        if error_msg:
            status.is_success = False
            kopf.event(
                body,
                type="Error",
                reason="PostgresConnector",
                message=error_msg,
            )

    return status
