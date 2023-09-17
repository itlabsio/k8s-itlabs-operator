import pytest

from connectors.sentry_connector import specifications
from connectors.sentry_connector.exceptions import SentryConnectorMissingRequiredAnnotationError, \
    SentryConnectorAnnotationEmptyValueError
from connectors.sentry_connector.factories.dto_factory import SentryConnectorMicroserviceDtoFactory


@pytest.mark.unit
class TestSentryConnectorMicroserviceDtoFactory:
    def test_annotation_contain_transform_environment_value(self):
        labels = {specifications.SENTRY_APP_NAME_LABEL: "value"}
        annotations = {x: "value" for x in specifications.SENTRY_CONNECTOR_REQUIRED_ANNOTATIONS}
        annotations[specifications.SENTRY_ENVIRONMENT_ANNOTATION] = "development"

        dto = SentryConnectorMicroserviceDtoFactory.dto_from_annotations(
            annotations, labels
        )

        assert dto.environment == "dev"

    def test_annotation_contain_unchangeable_environment_value(self):
        labels = {specifications.SENTRY_APP_NAME_LABEL: "value"}
        annotations = {x: "value" for x in specifications.SENTRY_CONNECTOR_REQUIRED_ANNOTATIONS}
        annotations[specifications.SENTRY_ENVIRONMENT_ANNOTATION] = "any"

        dto = SentryConnectorMicroserviceDtoFactory.dto_from_annotations(
            annotations, labels
        )

        assert dto.environment == "any"

    def test_all_annotations_exists(self):
        annotations = {key: "value" for key in specifications.SENTRY_CONNECTOR_ANNOTATIONS}
        labels = {}
        connector_dto = SentryConnectorMicroserviceDtoFactory.dto_from_annotations(annotations, labels)
        assert connector_dto

    def test_required_annotations_and_label_for_default_value_exists(self):
        annotations = {key: "value" for key in specifications.SENTRY_CONNECTOR_REQUIRED_ANNOTATIONS}
        labels = {"app": "application"}
        connector_dto = SentryConnectorMicroserviceDtoFactory.dto_from_annotations(annotations, labels)
        assert connector_dto

    def test_required_annotations_not_exist(self):
        annotations = {}
        labels = {"app": "application"}
        with pytest.raises(SentryConnectorMissingRequiredAnnotationError):
            SentryConnectorMicroserviceDtoFactory.dto_from_annotations(annotations, labels)

    def test_label_for_default_value_not_exists(self):
        annotations = {key: "value" for key in specifications.SENTRY_CONNECTOR_REQUIRED_ANNOTATIONS}
        labels = {}
        with pytest.raises(SentryConnectorAnnotationEmptyValueError):
            SentryConnectorMicroserviceDtoFactory.dto_from_annotations(annotations, labels)
