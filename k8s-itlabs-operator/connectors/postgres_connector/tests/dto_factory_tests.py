import pytest
from connectors.postgres_connector import specifications
from connectors.postgres_connector.exceptions import (
    PgConnectorAnnotationEmptyValueError,
    PgConnectorMissingRequiredAnnotationError,
)
from connectors.postgres_connector.factories.dto_factory import (
    PgConnectorMicroserviceDtoFactory,
)


@pytest.mark.unit
class TestPgConnectorMicroserviceDtoFactory:
    def test_all_annotations_exists(self):
        annotations = {
            key: "value" for key in specifications.PG_CON_ANNOTATION_NAMES
        }
        labels = {}
        connector_dto = PgConnectorMicroserviceDtoFactory.dto_from_annotations(
            annotations, labels
        )
        assert connector_dto

    def test_dto_from_annotations_with_default_value(self):
        annotations = {
            key: "value"
            for key in specifications.PG_CON_REQUIRED_ANNOTATION_NAMES
        }
        labels = {specifications.APP_NAME_LABEL: "srv"}
        dto = PgConnectorMicroserviceDtoFactory.dto_from_annotations(
            annotations=annotations, labels=labels
        )
        assert dto

    def test_dto_from_annotations_with_empty_value_and_default_value(self):
        annotations = {
            key: "" for key in specifications.PG_CON_ANNOTATION_NAMES
        }
        for key in specifications.PG_CON_REQUIRED_ANNOTATION_NAMES:
            annotations[key] = "value"
        labels = {specifications.APP_NAME_LABEL: "srv"}
        with pytest.raises(PgConnectorAnnotationEmptyValueError):
            PgConnectorMicroserviceDtoFactory.dto_from_annotations(
                annotations=annotations, labels=labels
            )

    def test_required_annotations_not_exist(self):
        annotations = {}
        labels = {
            "app": "application",
        }
        with pytest.raises(PgConnectorMissingRequiredAnnotationError):
            PgConnectorMicroserviceDtoFactory.dto_from_annotations(
                annotations, labels
            )

    def test_label_for_default_value_not_exist(self):
        annotations = {
            "postgres.connector.itlabs.io/instance-name": "postgres",
            "postgres.connector.itlabs.io/vault-path": "vault:secret/data/postgres",
        }
        labels = {}
        with pytest.raises(PgConnectorAnnotationEmptyValueError):
            PgConnectorMicroserviceDtoFactory.dto_from_annotations(
                annotations, labels
            )
