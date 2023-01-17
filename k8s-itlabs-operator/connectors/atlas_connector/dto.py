from dataclasses import dataclass
from typing import Optional

from connectors.atlas_connector import specifications
from connectors.atlas_connector.exceptions import AtlasAnnotationsEmptyValueException, \
    AtlasAnnotationsGitlabProjectIdValueException


@dataclass
class AtlasConfigDto:
    atlas_url: str
    vault_path: str
    cluster_dns: str


@dataclass
class AtlasMicroserviceDto:
    cluster_dns: str
    namespace: str
    ms_name: str
    gitlab_project_id: int
    business_name: Optional[str] = None


@dataclass
class AtlasConnectorAnnotations:
    _annotations: dict
    _is_connector_enabled: Optional[bool] = None

    @property
    def is_connector_enabled(self) -> bool:
        if not isinstance(self._is_connector_enabled, bool):
            self._is_connector_enabled = all(
                annotation_name in self._annotations
                for annotation_name in specifications.ATLAS_CON_REQUIRED_ANNOTATION_NAMES
            )
        return self._is_connector_enabled

    @property
    def ms_name(self) -> str:
        if self._annotations[specifications.ATLAS_MICROSERVICE_NAME_ANNOTATION]:
            return self._annotations[specifications.ATLAS_MICROSERVICE_NAME_ANNOTATION]
        raise AtlasAnnotationsEmptyValueException(annotation_name=specifications.ATLAS_MICROSERVICE_NAME_ANNOTATION)

    @property
    def gitlab_project_id(self) -> int:
        if not self._annotations[specifications.ANNOTATION_CI_PROJECT_ID]:
            raise AtlasAnnotationsEmptyValueException(annotation_name=specifications.ANNOTATION_CI_PROJECT_ID)
        try:
            return int(self._annotations[specifications.ANNOTATION_CI_PROJECT_ID])
        except ValueError as ex:
            raise AtlasAnnotationsGitlabProjectIdValueException(
                id_str=self._annotations[specifications.ANNOTATION_CI_PROJECT_ID], ex=ex)

    @property
    def business_name(self) -> Optional[str]:
        return self._annotations.get(specifications.ATLAS_BUSINESS_NAME_ANNOTATION)
