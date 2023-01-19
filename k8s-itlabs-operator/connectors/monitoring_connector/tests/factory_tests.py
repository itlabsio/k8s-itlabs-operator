import pytest

from connectors.monitoring_connector import specifications
from connectors.monitoring_connector.factories.dto_factory import MonitoringConnectorMicroserviceDtoFactory


@pytest.mark.unit
class TestMonitoringConnectorMicroserviceDtoFactory:
    def test_dto_empty_annotations(self):
        dto = MonitoringConnectorMicroserviceDtoFactory.dto_from_annotations(annotations={})
        assert dto.interval == specifications.DEFAULT_METRICS_INTERVAL
        assert dto.metric_path == specifications.DEFAULT_METRICS_PATH

    def test_dto_full_annotations(self):
        annotations = {
            specifications.MONITORING_INTERVAL_NAME_ANNOTATION: 'some_interval',
            specifications.MONITORING_PATH_NAME_ANNOTATION: 'some_path',
        }
        dto = MonitoringConnectorMicroserviceDtoFactory.dto_from_annotations(annotations=annotations)
        assert dto.interval == annotations[specifications.MONITORING_INTERVAL_NAME_ANNOTATION]
        assert dto.metric_path == annotations[specifications.MONITORING_PATH_NAME_ANNOTATION]
