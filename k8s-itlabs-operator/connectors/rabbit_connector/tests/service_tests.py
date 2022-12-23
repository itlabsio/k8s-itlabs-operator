import pytest

from connectors.rabbit_connector import specifications
from connectors.rabbit_connector.dto import RabbitConnector, RabbitConnectorMicroserviceDto
from connectors.rabbit_connector.exceptions import RabbitConnectorCrdDoesNotExist, UnknownVaultPathInRabbitConnector
from connectors.rabbit_connector.services.rabbit_connector import RabbitConnectorService
from connectors.rabbit_connector.tests.factories import RabbitConnectorMicroserviceDtoTestFactory, \
    RabbitApiSecretDtoTestFactory
from connectors.rabbit_connector.tests.mocks import MockedVaultService, KubernetesServiceMocker, \
    RabbitServiceFactoryMocker


@pytest.mark.unit
class TestRabbitConnectorService:
    def test_is_rabbit_conn_used_by_object_used(self):
        annotations = {
            'a': 'some',
            specifications.RABBIT_INSTANCE_NAME_ANNOTATION: 'rabbit',
            specifications.VAULTPATH_NAME_ANNOTATION: 'path',
        }
        is_used = RabbitConnectorService.is_rabbit_conn_used_by_object(annotations=annotations)
        assert is_used

    def test_is_rabbit_conn_used_by_object_unused(self):
        annotations = {}
        is_used = RabbitConnectorService.is_rabbit_conn_used_by_object(annotations=annotations)
        assert not is_used

    def test_on_create_deployment_no_crds(self, mocker):
        KubernetesServiceMocker.mock_get_rabbit_connector(mocker=mocker)
        ms_rabbit_con = RabbitConnectorMicroserviceDtoTestFactory()
        rabbit_connector_service = RabbitConnectorService(vault_service=MockedVaultService())
        with pytest.raises(RabbitConnectorCrdDoesNotExist):
            rabbit_connector_service.on_create_deployment(ms_rabbit_con=ms_rabbit_con)

    def test_on_create_deployment_no_rabbit_in_crds(self, mocker):
        rabbit_connector = RabbitConnector()
        KubernetesServiceMocker.mock_get_rabbit_connector(mocker=mocker, rabbit_connector=rabbit_connector)
        ms_rabbit_con = RabbitConnectorMicroserviceDtoTestFactory()
        rabbit_connector_service = RabbitConnectorService(vault_service=MockedVaultService())
        with pytest.raises(UnknownVaultPathInRabbitConnector):
            rabbit_connector_service.on_create_deployment(ms_rabbit_con=ms_rabbit_con)

    def test_on_create_deployment(self, mocker):
        rabbit_api_cred = RabbitApiSecretDtoTestFactory()
        ms_rabbit_con: RabbitConnectorMicroserviceDto = RabbitConnectorMicroserviceDtoTestFactory()
        rabbit_connector = RabbitConnector()
        rabbit_connector.add_rabbit_instance(
            name=ms_rabbit_con.rabbit_instance_name,
            vault_path=ms_rabbit_con.vault_path
        )
        KubernetesServiceMocker.mock_get_rabbit_connector(mocker=mocker, rabbit_connector=rabbit_connector)
        RabbitServiceFactoryMocker.mock_create_rabbit_service(mocker)
        rabbit_connector_service = RabbitConnectorService(
            vault_service=MockedVaultService(rabbit_api_cred=rabbit_api_cred)
        )
        rabbit_connector_service.on_create_deployment(ms_rabbit_con=ms_rabbit_con)

    def test_mutate_containers_variables_already_in_container(self):
        ms_rabbit_con: RabbitConnectorMicroserviceDto = RabbitConnectorMicroserviceDtoTestFactory()
        mocked_vault_service = MockedVaultService()
        rabbit_con_service = RabbitConnectorService(
            vault_service=mocked_vault_service
        )
        spec = {
            'containers': [
                {
                    'name': 'first',
                    'env': [
                        {
                            'name': var_name[0],
                            'value': 'some_value'
                        } for var_name in specifications.RABBIT_VAR_NAMES
                    ]
                }
            ]
        }
        assert not rabbit_con_service.mutate_containers(spec=spec, ms_rabbit_con=ms_rabbit_con)

    def test_mutate_containers_variables_not_in_container(self):
        ms_rabbit_con: RabbitConnectorMicroserviceDto = RabbitConnectorMicroserviceDtoTestFactory()
        mocked_vault_service = MockedVaultService()
        rabbit_con_service = RabbitConnectorService(
            vault_service=mocked_vault_service
        )
        spec = {'containers': [{'name': 'first'}]}
        assert rabbit_con_service.mutate_containers(spec=spec, ms_rabbit_con=ms_rabbit_con)
        assert rabbit_con_service.vault_service.get_vault_env_value_call_count == len(specifications.RABBIT_VAR_NAMES)

    def test_mutate_containers_variables_already_in_one_container_not_in_enother(self):
        ms_rabbit_con: RabbitConnectorMicroserviceDto = RabbitConnectorMicroserviceDtoTestFactory()
        mocked_vault_service = MockedVaultService()
        rabbit_con_service = RabbitConnectorService(
            vault_service=mocked_vault_service
        )
        spec = {
            'containers': [
                {
                    'name': 'first',
                    'env': [
                        {
                            'name': var_name[0],
                            'value': 'some_value'
                        } for var_name in specifications.RABBIT_VAR_NAMES
                    ]
                }, {
                    'name': 'second'
                }
            ]
        }
        assert rabbit_con_service.mutate_containers(spec=spec, ms_rabbit_con=ms_rabbit_con)
        assert rabbit_con_service.vault_service.get_vault_env_value_call_count == len(specifications.RABBIT_VAR_NAMES)
