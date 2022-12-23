from typing import Optional

from connectors.atlas_connector import specifications
from connectors.atlas_connector.dto import AtlasConfigDto, AtlasMicroserviceDto, AtlasConnectorAnnotations
from connectors.atlas_connector.exceptions import AtlasConfigMapException


class AtlasConfigDtoFactory:
    @classmethod
    def dto_from_dict(cls, configmap_data: dict) -> AtlasConfigDto:
        if not configmap_data:
            raise AtlasConfigMapException()
        if specifications.CONFIGMAP_ATLAS_URL_KEY not in configmap_data:
            raise AtlasConfigMapException(key=specifications.CONFIGMAP_ATLAS_URL_KEY)
        if specifications.CONFIGMAP_VAULT_PATH_KEY not in configmap_data:
            raise AtlasConfigMapException(key=specifications.CONFIGMAP_VAULT_PATH_KEY)
        if specifications.CONFIGMAP_CLUSTER_DNS_KEY not in configmap_data:
            raise AtlasConfigMapException(key=specifications.CONFIGMAP_CLUSTER_DNS_KEY)
        return AtlasConfigDto(
            atlas_url=configmap_data[specifications.CONFIGMAP_ATLAS_URL_KEY],
            vault_path=configmap_data[specifications.CONFIGMAP_VAULT_PATH_KEY],
            cluster_dns=configmap_data[specifications.CONFIGMAP_CLUSTER_DNS_KEY],
        )


class AtlasMicroserviceDtoFactory:
    @classmethod
    def dto_from_params(
            cls,
            cluster_dns: str,
            namespace: str,
            ms_name: str,
            gitlab_project_id: int,
            business_name: Optional[str]
    ) -> AtlasMicroserviceDto:
        return AtlasMicroserviceDto(
            cluster_dns=cluster_dns,
            namespace=namespace,
            ms_name=ms_name,
            gitlab_project_id=gitlab_project_id,
            business_name=business_name
        )

    @classmethod
    def dto_from_annotations(cls, cluster_dns: str, namespace: str,
                             annotations: AtlasConnectorAnnotations) -> AtlasMicroserviceDto:
        return AtlasMicroserviceDto(
            cluster_dns=cluster_dns,
            namespace=namespace,
            ms_name=annotations.ms_name,
            gitlab_project_id=annotations.gitlab_project_id,
            business_name=annotations.business_name
        )


class AtlasConnectorAnnotationsFactory:
    @classmethod
    def annotations_from_dict(cls, data: dict) -> AtlasConnectorAnnotations:
        return AtlasConnectorAnnotations(data)
