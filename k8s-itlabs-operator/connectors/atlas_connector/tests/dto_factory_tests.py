import pytest
from connectors.atlas_connector import specifications
from connectors.atlas_connector.exceptions import AtlasConfigMapException
from connectors.atlas_connector.factories.dto_factory import (
    AtlasConfigDtoFactory,
)


@pytest.mark.unit
class TestAtlasConfigDtoFactory:
    def test_dto_from_dict_success(self):
        data = {
            specifications.CONFIGMAP_ATLAS_URL_KEY: "",
            specifications.CONFIGMAP_VAULT_PATH_KEY: "",
            specifications.CONFIGMAP_CLUSTER_DNS_KEY: "",
        }
        atlas_config = AtlasConfigDtoFactory.dto_from_dict(configmap_data=data)
        assert atlas_config

    def test_dto_from_dict_with_error(self):
        data = {
            specifications.CONFIGMAP_ATLAS_URL_KEY: "",
            specifications.CONFIGMAP_CLUSTER_DNS_KEY: "",
        }
        with pytest.raises(AtlasConfigMapException) as err:
            AtlasConfigDtoFactory.dto_from_dict(configmap_data=data)
        assert specifications.CONFIGMAP_VAULT_PATH_KEY in str(err.value)

    def test_dto_from_dict_with_no_data(self):
        data = {}
        with pytest.raises(AtlasConfigMapException) as err:
            AtlasConfigDtoFactory.dto_from_dict(configmap_data=data)
        assert "does not exist data" in str(err.value)
