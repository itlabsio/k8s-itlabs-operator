import logging

import kopf

from exceptions import InfrastructureServiceProblem
from observability.metrics.decorator import monitoring
from operators.dto import ConnectorStatus
from connectors.postgres_connector.exceptions import PgConnectorCrdDoesNotExist, UnknownVaultPathInPgConnector
from connectors.postgres_connector.factories.dto_factory import PgConnectorMicroserviceDtoFactory
from connectors.postgres_connector.factories.service_factories.postgres_connector import PostgresConnectorServiceFactory
from connectors.postgres_connector.services.postgres_connector import PostgresConnectorService
from utils.common import OwnerReferenceDto, get_owner_reference


@kopf.on.create('postgresconnectors')
def create_fn(body, **_):
    logging.info(f"A handler is called with body: {body}")


@kopf.on.mutate('pods.v1', id='pg-con-on-createpods')
@monitoring(connector_type='postgres_connector')
def create_pods(body, patch, spec, annotations, labels, **_):
    owner_ref: OwnerReferenceDto = get_owner_reference(body)
    owner_fmt = f"{owner_ref.kind}: {owner_ref.name}" if owner_ref else ""

    logging.info(f"[{owner_fmt}] A postgres mutate handler is called on pod creating")
    status = ConnectorStatus(
        is_used=PostgresConnectorService.is_pg_conn_used_by_object(annotations)
    )
    if not status.is_used:
        logging.info(f"[{owner_fmt}] Postgres connector is not used, because no expected annotations")
        return status
    ms_pg_con = PgConnectorMicroserviceDtoFactory.dto_from_annotations(annotations, labels)
    pg_con_service = PostgresConnectorServiceFactory.create_postgres_connector_service()
    logging.info(f"[{owner_fmt}] Postgres connector service is created")
    try:
        pg_con_service.on_create_deployment(ms_pg_con)
        logging.info(f"[{owner_fmt}] Postgres connector service was processed in infrastructure")
    except (PgConnectorCrdDoesNotExist, UnknownVaultPathInPgConnector) as e:
        logging.error(f"[{owner_fmt}] Problem with Postgres connector", exc_info=e)
        status.is_enabled = False
        status.exception = e
    except InfrastructureServiceProblem as e:
        logging.error(f"[{owner_fmt}] Problem with infrastructure, some changes may not be applied", exc_info=e)
        status.is_enabled = True
        status.exception = e
    else:
        status.is_enabled = True
        if pg_con_service.mutate_containers(spec, ms_pg_con):
            patch.spec['containers'] = spec.get('containers', [])
            patch.spec['initContainers'] = spec.get('initContainers', [])
            logging.info(f"[{owner_fmt}] Postgres connector service patched containers, patch.spec: {patch.spec}")
    return status


@kopf.on.create("pods.v1", id="postgres-connector-on-check-creation")
def check_creation(annotations, body, spec, **_):
    if not PostgresConnectorService.is_pg_conn_used_by_object(annotations):
        return None

    if not PostgresConnectorService.containers_contain_required_envs(spec):
        kopf.event(
            body,
            type="Error",
            reason="PostgresConnector",
            message=f"Postgres Connector not applied",
        )
