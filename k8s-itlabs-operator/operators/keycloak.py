import logging

import kopf

from exceptions import InfrastructureServiceProblem
from connectors.keycloak_connector.exceptions import KeycloakConnectorError
from connectors.keycloak_connector.factories.dto_factory import \
    KeycloakConnectorMicroserviceDtoFactory as DtoFactory
from connectors.keycloak_connector.factories.service_factories.keycloak_connector import \
    KeycloakConnectorServiceFactory


@kopf.on.mutate("pods.v1", id="kk-con-on-createpods")
def create_pods(patch, spec, annotations, **_):
    logging.info("Keycloak mutate handler is called on pod created")

    kk_conn_service = KeycloakConnectorServiceFactory.create()
    logging.info("Keycloak connector service is created")

    if not kk_conn_service.is_kk_conn_used_by_obj(annotations):
        logging.info("Keycloak connector is not used, "
                     "because not expected annotations")
        return

    ms_keycloak_conn = DtoFactory.dto_from_metadata(annotations)
    try:
        kk_conn_service.on_create_deployment(ms_keycloak_conn)
    except KeycloakConnectorError as e:
        logging.error(e)
    except InfrastructureServiceProblem as e:
        logging.error("Problem with infrastructure, "
                      "some changes couldn't be applied",
                      exc_info=e)
    logging.info("Keycloak connector service was processed in infrastructure")

    if kk_conn_service.mutate_containers(spec, ms_keycloak_conn):
        patch.spec["containers"] = spec.get("containers", [])
        patch.spec["initContainers"] = spec.get("initContainers", [])
        logging.info(f"Keycloak connector service patched containers, "
                     f"patch.spec: {patch.spec}")
