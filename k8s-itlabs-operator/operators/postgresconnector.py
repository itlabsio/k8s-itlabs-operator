import logging

import kopf

from exceptions import InfrastructureServiceProblem
from observability.metrics.decorator import monitoring
from operators.dto import ConnectorStatus
from connectors.postgres_connector.exceptions import PgConnectorCrdDoesNotExist, UnknownVaultPathInPgConnector
from connectors.postgres_connector.factories.dto_factory import PgConnectorMicroserviceDtoFactory
from connectors.postgres_connector.factories.service_factories.postgres_connector import PostgresConnectorServiceFactory
from connectors.postgres_connector.services.postgres_connector import PostgresConnectorService


@kopf.on.create('postgresconnectors')
def create_fn(body, **kwargs):
    logging.info(f"A handler is called with body: {body}")


@kopf.on.mutate('pods.v1', id='pg-con-on-createpods')
@monitoring(connector_type='postgres_connector')
def create_pods(patch, spec, annotations, labels, body, **kwargs):
    logging.info("A postgres mutate handler is called on pod creating")
    status = ConnectorStatus(
        is_used=PostgresConnectorService.is_pg_conn_used_by_object(annotations)
    )
    if not status.is_used:
        logging.info("Postgres connector is not used, because no expected annotations")
        return status
    ms_pg_con = PgConnectorMicroserviceDtoFactory.dto_from_annotations(annotations, labels)
    pg_con_service = PostgresConnectorServiceFactory.create_postgres_connector_service()
    logging.info("Postgres connector service is created")
    try:
        pg_con_service.on_create_deployment(ms_pg_con)
        logging.info("Postgres connector service was processed in infrastructure")
    except (PgConnectorCrdDoesNotExist, UnknownVaultPathInPgConnector):
        status.is_enabled = False
    except InfrastructureServiceProblem as e:
        logging.error('Problem with infrastructure, some changes may not be applied', exc_info=e)
        status.is_enabled = True
        status.exception = e
    else:
        status.is_enabled = True
        if pg_con_service.mutate_containers(spec, ms_pg_con):
            patch.spec['containers'] = spec.get('containers', [])
            patch.spec['initContainers'] = spec.get('initContainers', [])
            logging.info(f"Postgres connector service patched containers, patch.spec: {patch.spec}")
    return status
