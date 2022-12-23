from connectors.monitoring_connector import specifications
from connectors.monitoring_connector.dto import MonitoringConnectorMicroserviceDto


class MonitoringConnectorMicroserviceDtoFactory:
    @classmethod
    def dto_from_annotations(cls, annotations: dict) -> MonitoringConnectorMicroserviceDto:
        return MonitoringConnectorMicroserviceDto(
            metric_path=annotations.get(specifications.MONITORING_PATH_NAME_ANNOTATION,
                                        specifications.DEFAULT_METRICS_PATH),
            interval=annotations.get(specifications.MONITORING_INTERVAL_NAME_ANNOTATION,
                                     specifications.DEFAULT_METRICS_INTERVAL)
        )
