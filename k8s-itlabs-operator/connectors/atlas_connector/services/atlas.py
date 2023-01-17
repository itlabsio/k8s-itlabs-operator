from abc import ABCMeta, abstractmethod
from typing import Dict

import requests

from connectors.atlas_connector.specifications import ATLAS_TIMEOUT
from connectors.atlas_connector.dto import AtlasMicroserviceDto
from connectors.atlas_connector.presenters import AtlasMicroserviceDtoPresenter
from exceptions import InfrastructureServiceProblem


class AbstractAtlasService:
    __metaclass__ = ABCMeta

    @abstractmethod
    def update_microservice(self, atlas_microservice_dto: AtlasMicroserviceDto):
        raise NotImplementedError


class AtlasService(AbstractAtlasService):
    def __init__(self, atlas_url: str, atlas_token: str):
        self._atlas_url = atlas_url
        self._atlas_token = atlas_token

    def _get_headers(self) -> Dict[str, str]:
        return {"Authorization": f"Bearer {self._atlas_token}"}

    def update_microservice(self, atlas_microservice_dto: AtlasMicroserviceDto):
        url = f'{self._atlas_url}/private/api/1/atlas-connector'
        data = AtlasMicroserviceDtoPresenter.atlas_dict_from_dto(atlas_ms_dto=atlas_microservice_dto)
        try:
            requests.post(
                url=url,
                json=data,
                headers=self._get_headers(),
                timeout=ATLAS_TIMEOUT
            )
        except Exception as ex:
            raise InfrastructureServiceProblem('Atlas', ex)
