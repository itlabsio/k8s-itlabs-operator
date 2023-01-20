import logging

import kopf

from connectors.monitoring_connector.factories.service_factories.monitoring_connector import \
    MonitoringConnectorServiceFactory
from observability.metrics.decorator import monitoring
from connectors.monitoring_connector.factories.dto_factory import MonitoringConnectorMicroserviceDtoFactory
from operators.dto import ConnectorStatus


@kopf.on.create("services")
@kopf.on.update("services")
@monitoring(connector_type='monitoring_connector')
def create_services(namespace, name, annotations, **_):
    logging.info("A mutate handler is called on service creating")
    status = ConnectorStatus()
    monitoring_connector_service = MonitoringConnectorServiceFactory.create_monitoring_connector_service()
    status.is_used = monitoring_connector_service.is_monitoring_connector_used_by_object(annotations)
    if status.is_used:
        ms_mon_con_dto = MonitoringConnectorMicroserviceDtoFactory.dto_from_annotations(annotations)
        created = monitoring_connector_service.create_service_monitor(ms_mon_con_dto, name, namespace)
        status.is_enabled = created
    else:
        logging.info("Monitoring connector is not used, because no expected annotations")
        monitoring_connector_service.delete_service_monitor(namespace, name)
    return status


@kopf.on.delete("services")
def delete_services(namespace, name, **_):
    logging.info("A mutate handler is called on service creating")
    monitoring_connector_service = MonitoringConnectorServiceFactory.create_monitoring_connector_service()
    monitoring_connector_service.delete_service_monitor(namespace, name)
