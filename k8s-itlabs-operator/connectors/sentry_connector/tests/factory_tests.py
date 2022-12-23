import pytest

from connectors.sentry_connector import specifications
from connectors.sentry_connector.exceptions import EnvironmentValueError
from connectors.sentry_connector.factories.dto_factory import SentryConnectorMicroserviceDtoFactory


@pytest.mark.unit
class TestSentryConnectorMicroserviceDtoFactory:

    def test_label_contain_incorrect_environment_value(self):
        annotations = {specifications.SENTRY_ENVIRONMENT_ANNOTATION: "dev"}
        labels = {}

        with pytest.raises(EnvironmentValueError):
            SentryConnectorMicroserviceDtoFactory.dto_from_annotations(annotations, labels)
