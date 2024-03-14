import pytest
from connectors.monitoring_connector import specifications
from connectors.monitoring_connector.service import MonitoringConnectorService


@pytest.mark.unit
class TestMonitoringConnectorService:
    def test_is_monitoring_connector_used_by_object_not_used(self):
        is_used = (
            MonitoringConnectorService.is_monitoring_connector_used_by_object(
                annotations={}
            )
        )
        assert not is_used

    def test_is_monitoring_connector_used_by_object_not_used_turned_of(self):
        annotations = {
            specifications.MONITORING_ENABLED_NAME_ANNOTATION: "false"
        }
        is_used = (
            MonitoringConnectorService.is_monitoring_connector_used_by_object(
                annotations=annotations
            )
        )
        assert not is_used

    def test_is_monitoring_connector_used_by_object_used(self):
        annotations = {
            specifications.MONITORING_ENABLED_NAME_ANNOTATION: "True"
        }
        is_used = (
            MonitoringConnectorService.is_monitoring_connector_used_by_object(
                annotations=annotations
            )
        )
        assert is_used
