from dataclasses import dataclass


@dataclass
class MonitoringConnectorMicroserviceDto:
    metric_path: str
    interval: str
