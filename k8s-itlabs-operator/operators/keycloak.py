import logging

import kopf

from exceptions import InfrastructureServiceProblem
from observability.metrics.decorator import monitoring, mutation_hook_monitoring
from operators.dto import ConnectorStatus, MutationHookStatus
from connectors.keycloak_connector.services.keycloak_connector import \
    KeycloakConnectorService
from connectors.keycloak_connector.exceptions import KeycloakConnectorError, \
    KeycloakConnectorMissingRequiredAnnotationError, KeycloakConnectorAnnotationEmptyValueError
from connectors.keycloak_connector.factories.dto_factory import \
    KeycloakConnectorMicroserviceDtoFactory as DtoFactory
from connectors.keycloak_connector.factories.service_factories.keycloak_connector import \
    KeycloakConnectorServiceFactory
from connectors.keycloak_connector.factories.service_factories.validation import \
    KeycloakConnectorValidationServiceFactory
from utils.common import OwnerReferenceDto, get_owner_reference


@kopf.on.mutate("pods.v1", id="kk-con-on-createpods")
@monitoring(connector_type='keycloak_connector')
def create_pods(body, patch, spec, annotations, **_):
    # At the time of the creation of Pod, the name and uid were not yet
    # set in the manifest, so in the logs we refer to its owner.
    owner_ref: OwnerReferenceDto = get_owner_reference(body)
    owner_fmt = f"{owner_ref.kind}: {owner_ref.name}" if owner_ref else ""

    logging.info(f"[{owner_fmt}] Keycloak mutate handler is called on pod creating")
    status = ConnectorStatus()
    try:
        ms_keycloak_conn = DtoFactory.dto_from_metadata(annotations)
    except KeycloakConnectorMissingRequiredAnnotationError as e:
        status.is_used = False
        logging.info(f"[{owner_fmt}] Keycloak connector is not used, reason: {e.message}")
        return status
    except KeycloakConnectorAnnotationEmptyValueError as e:
        logging.error(f"[{owner_fmt}] Problem with Keycloak connector: {e.message}", exc_info=e)
        status.is_used = True
        status.exception = e
        return status
    status.is_used = True
    kk_conn_service = KeycloakConnectorServiceFactory.create()
    logging.info(f"[{owner_fmt}] Keycloak connector service is created")
    try:
        kk_conn_service.on_create_deployment(ms_keycloak_conn)
        logging.info(f"[{owner_fmt}] Keycloak connector service was processed in infrastructure")
    except KeycloakConnectorError as e:
        logging.error(f"[{owner_fmt}] Problem with Keycloak connector", exc_info=e)
        status.is_enabled = False
        status.exception = e
    except InfrastructureServiceProblem as e:
        logging.error(f"[{owner_fmt}] Problem with infrastructure, "
                      "some changes couldn't be applied",
                      exc_info=e)
        status.is_enabled = True
        status.exception = e
    else:
        status.is_enabled = True
        if kk_conn_service.mutate_containers(spec, ms_keycloak_conn):
            patch.spec["containers"] = spec.get("containers", [])
            patch.spec["initContainers"] = spec.get("initContainers", [])
            logging.info(f"[{owner_fmt}] Keycloak connector service patched containers, "
                         f"patch.spec: {patch.spec}")
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
        logging.error(f"[{name}] Problem with Keycloak connector: {e.message}", exc_info=e)
        status.is_used = True
        status.exception = e
        return status

    status.is_success = True
    spec = body.get("spec", {})
    if not KeycloakConnectorService.any_containers_contain_required_envs(spec):
        status.is_success = False

        service = KeycloakConnectorValidationServiceFactory.create()
        errors = service.validate(ms_keycloak_conn)
        if errors:
            reasons = "; ".join(str(e) for e in errors)
            kopf.event(
                body,
                type="Error",
                reason="KeycloakConnector",
                message=f"Keycloak Connector not applied for next reasons: {reasons}"
            )
        else:
            kopf.event(
                body,
                type="Error",
                reason="KeycloakConnector",
                message=(
                    "Keycloak Connector not applied by unknown reasons. "
                    "It's maybe problems with infrastructure or certificates."
                )
            )

    return status
