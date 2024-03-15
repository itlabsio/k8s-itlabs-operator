import pytest
from connectors.rabbit_connector import specifications
from connectors.rabbit_connector.exceptions import (
    RabbitConnectorAnnotationEmptyValueError,
    RabbitConnectorMissingRequiredAnnotationError,
)
from connectors.rabbit_connector.factories.dto_factory import (
    RabbitConnectorMicroserviceDtoFactory,
)


@pytest.mark.unit
class TestRabbitConnectorMicroserviceDtoFactory:
    def test_all_annotations_exists(self):
        annotations = {
            key: "value" for key in specifications.RABBIT_CONNECTOR_ANNOTATIONS
        }
        labels = {}
        connector_dto = (
            RabbitConnectorMicroserviceDtoFactory.dto_from_annotations(
                annotations, labels
            )
        )
        assert connector_dto

    def test_required_annotations_and_label_for_default_value_exist(self):
        annotations = {
            key: "value"
            for key in specifications.RABBIT_CONNECTOR_REQUIRED_ANNOTATIONS
        }
        labels = {"app": "application"}
        connector_dto = (
            RabbitConnectorMicroserviceDtoFactory.dto_from_annotations(
                annotations, labels
            )
        )
        assert connector_dto

    def test_required_annotations_not_exist(self):
        annotations = {}
        labels = {"app": "application"}
        with pytest.raises(RabbitConnectorMissingRequiredAnnotationError):
            RabbitConnectorMicroserviceDtoFactory.dto_from_annotations(
                annotations, labels
            )

    def test_label_for_default_value_not_exist(self):
        annotations = {
            key: "value"
            for key in specifications.RABBIT_CONNECTOR_REQUIRED_ANNOTATIONS
        }
        labels = {}
        with pytest.raises(RabbitConnectorAnnotationEmptyValueError):
            RabbitConnectorMicroserviceDtoFactory.dto_from_annotations(
                annotations, labels
            )
