import logging

import kopf

from observability.metrics.decorator import monitoring
from connectors.monitoring_connector.factory import MonitoringConnectorMicroserviceDtoFactory
from connectors.monitoring_connector.service import MonitoringConnectorService
from operators.dto import ConnectorStatus


@kopf.on.create("services")
@kopf.on.update("services")
@monitoring(connector_type='monitoring_connector')
def create_services(namespace, name, annotations, **_):
    logging.info("A mutate handler is called on service creating")
    status = ConnectorStatus()
    status.is_used = MonitoringConnectorService.is_monitoring_connector_used_by_object(annotations)
    if status.is_used:
        ms_mon_con_dto = MonitoringConnectorMicroserviceDtoFactory.dto_from_annotations(annotations)
        created = MonitoringConnectorService.create_service_monitor(ms_mon_con_dto, name, namespace)
        status.is_enabled = created
    else:
        logging.info("Monitoring connector is not used, because no expected annotations")
        MonitoringConnectorService.delete_service_monitor(name, namespace)
    return status


@kopf.on.delete("services")
def delete_services(namespace, name, **_):
    logging.info("A mutate handler is called on service creating")
    MonitoringConnectorService.delete_service_monitor(name, namespace)
