import pytest

from connectors.sentry_connector import specifications
from connectors.sentry_connector.factories.dto_factory import SentryConnectorMicroserviceDtoFactory


@pytest.mark.unit
class TestSentryConnectorMicroserviceDtoFactory:

    def test_annotation_contain_transform_environment_value(self):
        labels = {}
        annotations = {
            specifications.SENTRY_ENVIRONMENT_ANNOTATION: "development"
        }

        dto = SentryConnectorMicroserviceDtoFactory.dto_from_annotations(
            annotations, labels
        )

        assert dto.environment == "dev"

    def test_annotation_contain_unchangeable_environment_value(self):
        labels = {}
        annotations = {specifications.SENTRY_ENVIRONMENT_ANNOTATION: "any"}

        dto = SentryConnectorMicroserviceDtoFactory.dto_from_annotations(
            annotations, labels
        )

        assert dto.environment == "any"
