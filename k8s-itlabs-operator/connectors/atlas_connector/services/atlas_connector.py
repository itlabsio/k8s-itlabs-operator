import logging

from connectors.atlas_connector import specifications
from connectors.atlas_connector.dto import AtlasConnectorAnnotations, AtlasConfigDto, AtlasMicroserviceDto
from connectors.atlas_connector.factories.dto_factory import AtlasMicroserviceDtoFactory
from connectors.atlas_connector.factories.service_factories.atlas import AtlasServiceFactory
from connectors.atlas_connector.factories.service_factories.vault import VaultServiceFactory
from connectors.atlas_connector.services.kubernetes import KubernetesService
from exceptions import InfrastructureServiceProblem
from operators.dto import ConnectorStatus


class AtlasConnectorService:
    @staticmethod
    def is_atlas_connector_enabled() -> bool:
        enabled = False
        try:
            KubernetesService.get_atlas_config()
            enabled = True
        finally:
            return enabled

    @classmethod
    def on_upsert_pod(cls, namespace: str, annotations: AtlasConnectorAnnotations) -> ConnectorStatus:
        status = ConnectorStatus()
        status.is_used = annotations.is_connector_enabled
        if not status.is_used:
            logging.info("Atlas connector is not used, because no expected annotations")
            return status
        status.is_enabled = cls.is_atlas_connector_enabled()
        if not status.is_enabled:
            logging.info(
                f"Atlas connector is not enabled, because no expected configmap: {specifications.CONFIGMAP_NAME}")
            return status
        atlas_config_dto = KubernetesService.get_atlas_config()
        atlas_ms_dto = AtlasMicroserviceDtoFactory.dto_from_annotations(
            cluster_dns=atlas_config_dto.cluster_dns,
            namespace=namespace,
            annotations=annotations
        )
        try:
            cls.update_microservice(atlas_config_dto, atlas_ms_dto)
        except InfrastructureServiceProblem as e:
            logging.error('Problem with infrastructure, some changes may not be applied', exc_info=e)
            status.exception = e
        return status

    @classmethod
    def update_microservice(cls, atlas_config_dto: AtlasConfigDto, atlas_ms_dto: AtlasMicroserviceDto):
        """send to atlas info about service and environment"""
        vault_service = VaultServiceFactory.create_vault_service()
        atlas_token = vault_service.get_atlas_token(vault_path=atlas_config_dto.vault_path)
        atlas_service = AtlasServiceFactory.create_atlas_service(
            atlas_url=atlas_config_dto.atlas_url,
            atlas_token=atlas_token
        )
        atlas_service.update_microservice(atlas_microservice_dto=atlas_ms_dto)
