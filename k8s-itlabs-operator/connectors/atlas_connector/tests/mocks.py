from typing import Optional

from connectors.atlas_connector.dto import AtlasConfigDto, AtlasMicroserviceDto
from connectors.atlas_connector.services.atlas import AbstractAtlasService
from connectors.atlas_connector.services.vault import AbstractVaultService


class MockedVaultService(AbstractVaultService):
    def get_atlas_token(self, vault_path: str) -> str:
        pass


class MockedAtlasService(AbstractAtlasService):
    def update_microservice(self, atlas_microservice_dto: AtlasMicroserviceDto):
        pass


class KubernetesServiceMocker:
    @staticmethod
    def mock_get_atlas_config(
        mocker,
        atlas_config_dto: Optional[AtlasConfigDto] = None,
        err: Optional[Exception] = None,
    ):
        if not err:
            mocker.patch(
                "connectors.atlas_connector.services.kubernetes.KubernetesService.get_atlas_config",
                return_value=atlas_config_dto,
            )
        else:
            mocker.patch(
                "connectors.atlas_connector.services.kubernetes.KubernetesService.get_atlas_config",
                side_effect=err,
            )
