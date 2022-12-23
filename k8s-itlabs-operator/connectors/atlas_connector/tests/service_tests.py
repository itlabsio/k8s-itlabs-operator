import pytest

from connectors.atlas_connector import specifications
from connectors.atlas_connector.dto import AtlasConfigDto
from connectors.atlas_connector.services.atlas_connector import AtlasConnectorService
from connectors.atlas_connector.services.kubernetes import KubernetesService
from connectors.atlas_connector.tests.mocks import KubernetesServiceMocker
from clients.k8s.tests.mocks import KubernetesClientMocker


@pytest.mark.unit
class TestAtlasConnectorService:
    def test_is_atlas_connector_enabled_success(self, mocker):
        KubernetesServiceMocker.mock_get_atlas_config(mocker)
        is_enabled = AtlasConnectorService.is_atlas_connector_enabled()
        assert is_enabled

    def test_is_atlas_connector_enabled_not(self, mocker):
        KubernetesServiceMocker.mock_get_atlas_config(mocker, err=Exception())
        is_enabled = AtlasConnectorService.is_atlas_connector_enabled()
        assert not is_enabled


@pytest.mark.unit
class TestKubernetesService:
    def test_get_atlas_config(self, mocker):
        data = {
            specifications.CONFIGMAP_ATLAS_URL_KEY: '',
            specifications.CONFIGMAP_VAULT_PATH_KEY: '',
            specifications.CONFIGMAP_CLUSTER_DNS_KEY: '',

        }
        KubernetesClientMocker.mock_get_configmap_data(mocker, data)
        annotations = KubernetesService.get_atlas_config()
        assert isinstance(annotations, AtlasConfigDto)
