import logging

import kopf
from connectors.keycloak_connector.exceptions import (
    KeycloakConnectorAnnotationEmptyValueError,
    KeycloakConnectorError,
    KeycloakConnectorMissingRequiredAnnotationError,
)
from connectors.keycloak_connector.factories.dto_factory import (
    KeycloakConnectorMicroserviceDtoFactory as DtoFactory,
)
from connectors.keycloak_connector.factories.service_factories.keycloak_connector import (
    KeycloakConnectorServiceFactory,
)
from connectors.keycloak_connector.factories.service_factories.validation import (
    KeycloakConnectorValidationServiceFactory,
)
from connectors.keycloak_connector.services.keycloak_connector import (
    KeycloakConnectorService,
)
from exceptions import InfrastructureServiceProblem
from observability.metrics.decorator import monitoring, mutation_hook_monitoring
from operators.dto import ConnectorStatus, MutationHookStatus
from utils.common import OwnerReferenceDto, get_owner_reference


@kopf.on.mutate("pods.v1", id="kk-con-on-createpods")
@monitoring(connector_type="keycloak_connector")
def create_pods(body, patch, spec, annotations, **_):
    # At the time of the creation of Pod, the name and uid were not yet
    # set in the manifest, so in the logs we refer to its owner.
    owner_ref: OwnerReferenceDto = get_owner_reference(body)
    owner_fmt = f"{owner_ref.kind}: {owner_ref.name}" if owner_ref else ""

    logging.info(
        "[%s] Keycloak mutate handler is called on pod creating" % (owner_fmt,)
    )
    status = ConnectorStatus()
    try:
        ms_keycloak_conn = DtoFactory.dto_from_metadata(annotations)
    except KeycloakConnectorMissingRequiredAnnotationError as e:
        status.is_used = False
        logging.info(
            "[%(owner)s] Keycloak connector is not used, reason: %(error)s"
            % {"owner": owner_fmt, "error": e.message}
        )
        return status
    except KeycloakConnectorAnnotationEmptyValueError as e:
        logging.error(
            "[%(owner)s] Problem with Keycloak connector: %(error)s"
            % {"owner": owner_fmt, "error": e.message},
            exc_info=e,
        )
        status.is_used = True
        status.exception = e
        return status
    status.is_used = True
    kk_conn_service = KeycloakConnectorServiceFactory.create()
    logging.info("[%s] Keycloak connector service is created" % (owner_fmt,))
    try:
        kk_conn_service.on_create_deployment(ms_keycloak_conn)
        logging.info(
            "[%s] Keycloak connector service was processed in infrastructure"
            % (owner_fmt,)
        )
    except KeycloakConnectorError as e:
        logging.error(
            "[%s] Problem with Keycloak connector" % (owner_fmt,), exc_info=e
        )
        status.is_enabled = False
        status.exception = e
    except InfrastructureServiceProblem as e:
        logging.error(
            "[%s] Problem with infrastructure, some changes couldn't be applied"
            % (owner_fmt,),
            exc_info=e,
        )
        status.is_enabled = True
        status.exception = e
    else:
        status.is_enabled = True
        if kk_conn_service.mutate_containers(spec, ms_keycloak_conn):
            patch.spec["containers"] = spec.get("containers", [])
            patch.spec["initContainers"] = spec.get("initContainers", [])
            logging.info(
                "[%(owner)s] Keycloak connector service patched containers, "
                "patch.spec: %(spec)s"
                % {"owner": owner_fmt, "spec": patch.spec}
            )
    return status


@kopf.on.create("pods.v1", id="keycloak-connector-on-check-creation")
@mutation_hook_monitoring(connector_type="keycloak_connector")
def check_creation(annotations, name, body, **_):
    status = MutationHookStatus()
    try:
        ms_keycloak_conn = DtoFactory.dto_from_metadata(annotations)
    except KeycloakConnectorMissingRequiredAnnotationError:
        status.is_used = False
        return status
    except KeycloakConnectorAnnotationEmptyValueError as e:
        logging.error(
            "[%(name)s] Problem with Keycloak connector: %(error)s"
            % {"name": name, "error": e.message},
            exc_info=e,
        )
        status.is_used = True
        status.exception = e
        return status

    status.is_success = True

    owner = get_owner_reference(body)
    status.owner = f"{owner.kind}: {owner.name}" if owner else ""

    spec = body.get("spec", {})
    if not KeycloakConnectorService.any_containers_contain_required_envs(spec):
        status.is_success = False

        service = KeycloakConnectorValidationServiceFactory.create()
        error_msg = (
            "Keycloak Connector not applied by unknown reasons. "
            "It's maybe problems with infrastructure or certificates."
        )
        if errors := service.validate(ms_keycloak_conn):
            reasons = "; ".join(str(e) for e in errors)
            error_msg = (
                f"Keycloak Connector not applied for next reasons: {reasons}"
            )

        kopf.event(
            body,
            type="Error",
            reason="KeycloakConnector",
            message=error_msg,
        )

    return status
