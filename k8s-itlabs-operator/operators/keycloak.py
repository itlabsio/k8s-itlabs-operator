import logging

import kopf

from exceptions import InfrastructureServiceProblem
from observability.metrics.decorator import monitoring
from operators.dto import ConnectorStatus
from connectors.keycloak_connector.services.keycloak_connector import \
    KeycloakConnectorService
from connectors.keycloak_connector.exceptions import KeycloakConnectorError
from connectors.keycloak_connector.factories.dto_factory import \
    KeycloakConnectorMicroserviceDtoFactory as DtoFactory
from connectors.keycloak_connector.factories.service_factories.keycloak_connector import \
    KeycloakConnectorServiceFactory
from connectors.keycloak_connector.specifications import \
    KEYCLOAK_INSTANCE_NAME_ANNOTATION


@kopf.on.mutate("pods.v1", id="kk-con-on-createpods")
@monitoring(connector_type='keycloak_connector')
def create_pods(patch, spec, annotations, **_):
    logging.info("Keycloak mutate handler is called on pod creating")
    status = ConnectorStatus(
        is_used=KeycloakConnectorService.is_kk_conn_used_by_obj(annotations)
    )
    if not status.is_used:
        logging.info("Keycloak connector is not used, "
                     "because not expected annotations")
        return status

    kk_conn_service = KeycloakConnectorServiceFactory.create()
    ms_keycloak_conn = DtoFactory.dto_from_metadata(annotations)
    logging.info("Keycloak connector service is created")
    try:
        kk_conn_service.on_create_deployment(ms_keycloak_conn)
        logging.info("Keycloak connector service was processed in infrastructure")
    except KeycloakConnectorError as e:
        logging.error(e)
        status.is_enabled = False
    except InfrastructureServiceProblem as e:
        logging.error("Problem with infrastructure, "
                      "some changes couldn't be applied",
                      exc_info=e)
        status.is_enabled = True
        status.exception = e
    else:
        status.is_enabled = True
        if kk_conn_service.mutate_containers(spec, ms_keycloak_conn):
            patch.spec["containers"] = spec.get("containers", [])
            patch.spec["initContainers"] = spec.get("initContainers", [])
            logging.info(f"Keycloak connector service patched containers, "
                         f"patch.spec: {patch.spec}")
    return status


@kopf.on.create("pods.v1", id="keycloak-connector-on-check-creation")
def check_creation(annotations, body, spec, **_):
    if not KeycloakConnectorService.is_kk_conn_used_by_obj(annotations):
        return None

    if not KeycloakConnectorService.containers_contain_required_envs(spec):
        cr_name = annotations.get(KEYCLOAK_INSTANCE_NAME_ANNOTATION, "")
        kopf.event(
            body,
            type="Error",
            reason="KeycloakConnector",
            message=f"Keycloak Custom Resource `{cr_name}` does not exist",
        )
