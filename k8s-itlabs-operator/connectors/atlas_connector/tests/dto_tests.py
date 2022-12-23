import pytest

from connectors.atlas_connector import specifications
from connectors.atlas_connector.dto import AtlasConnectorAnnotations
from connectors.atlas_connector.exceptions import AtlasAnnotationsEmptyValueException, \
    AtlasAnnotationsGitlabProjectIdValueException


@pytest.mark.unit
class TestAtlasConnectorAnnotations:
    def test_is_connector_enabled_no_annotations(self):
        annotations_dict = {}
        annotations = AtlasConnectorAnnotations(annotations_dict)
        assert not annotations.is_connector_enabled

    def test_is_connector_enabled_no_values(self):
        annotations_dict = {}
        for annotation_name in specifications.ATLAS_CON_REQUIRED_ANNOTATION_NAMES:
            annotations_dict[annotation_name] = None
        annotations = AtlasConnectorAnnotations(annotations_dict)
        assert annotations.is_connector_enabled

    def test_ms_name_no_values(self):
        annotations_dict = {}
        for annotation_name in specifications.ATLAS_CON_REQUIRED_ANNOTATION_NAMES:
            annotations_dict[annotation_name] = None
        annotations = AtlasConnectorAnnotations(annotations_dict)
        with pytest.raises(AtlasAnnotationsEmptyValueException) as err:
            ms_name = annotations.ms_name
            assert not ms_name
        assert specifications.ATLAS_MICROSERVICE_NAME_ANNOTATION in str(err.value)

    def test_ms_name_success(self):
        annotations_dict = {}
        expected_ms_name = 'some'
        for annotation_name in specifications.ATLAS_CON_REQUIRED_ANNOTATION_NAMES:
            annotations_dict[annotation_name] = None
        annotations_dict[specifications.ATLAS_MICROSERVICE_NAME_ANNOTATION] = expected_ms_name
        annotations = AtlasConnectorAnnotations(annotations_dict)
        ms_name = annotations.ms_name
        assert ms_name
        assert expected_ms_name == ms_name

    def test_gitlab_project_id_empty(self):
        annotations_dict = {}
        for annotation_name in specifications.ATLAS_CON_REQUIRED_ANNOTATION_NAMES:
            annotations_dict[annotation_name] = None
        annotations = AtlasConnectorAnnotations(annotations_dict)
        with pytest.raises(AtlasAnnotationsEmptyValueException) as err:
            gl_project_id = annotations.gitlab_project_id
            assert not gl_project_id
        assert specifications.ANNOTATION_CI_PROJECT_ID in str(err.value)

    def test_gitlab_project_id_non_digit(self):
        annotations_dict = {}
        non_digit_id = '123digit'
        for annotation_name in specifications.ATLAS_CON_REQUIRED_ANNOTATION_NAMES:
            annotations_dict[annotation_name] = None
        annotations_dict[specifications.ANNOTATION_CI_PROJECT_ID] = non_digit_id
        annotations = AtlasConnectorAnnotations(annotations_dict)
        with pytest.raises(AtlasAnnotationsGitlabProjectIdValueException) as err:
            gl_project_id = annotations.gitlab_project_id
            assert not gl_project_id
        assert specifications.ANNOTATION_CI_PROJECT_ID in str(err.value)
        assert non_digit_id in str(err.value)

    def test_business_name_is_empty(self):
        annotations_dict = {}
        annotations = AtlasConnectorAnnotations(annotations_dict)
        business_name = annotations.business_name
        assert business_name is None

    def test_business_name_is_not_empty(self):
        expected_business_name = 'some-business'
        annotations_dict = {
            specifications.ATLAS_BUSINESS_NAME_ANNOTATION: expected_business_name
        }
        annotations = AtlasConnectorAnnotations(annotations_dict)
        business_name = annotations.business_name
        assert isinstance(business_name, str)
        assert business_name == expected_business_name
