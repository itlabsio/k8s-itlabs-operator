import pytest

from clients.vault.tests.mocks import MockedVaultClient
from connectors.rabbit_connector import specifications
from connectors.rabbit_connector.dto import RabbitConnector, \
    RabbitConnectorMicroserviceDto, RabbitApiSecretDto
from connectors.rabbit_connector.exceptions import RabbitConnectorCrdDoesNotExist, UnknownVaultPathInRabbitConnector, \
    RabbitConnectorApplicationError
from connectors.rabbit_connector.factories.dto_factory import \
    RabbitConnectorMicroserviceDtoFactory
from connectors.rabbit_connector.services.rabbit_connector import RabbitConnectorService
from connectors.rabbit_connector.services.validation import \
    RabbitConnectorValidationService
from connectors.rabbit_connector.tests.factories import RabbitConnectorMicroserviceDtoTestFactory, \
    RabbitApiSecretDtoTestFactory
from connectors.rabbit_connector.tests.mocks import MockedVaultService, \
    KubernetesServiceMocker, \
    RabbitServiceFactoryMocker, MockKubernetesService


@pytest.mark.unit
class TestRabbitConnectorService:
    def test_on_create_deployment_no_crds(self, mocker):
        KubernetesServiceMocker.mock_get_rabbit_connector(mocker=mocker)
        ms_rabbit_con = RabbitConnectorMicroserviceDtoTestFactory()
        rabbit_connector_service = RabbitConnectorService(vault_service=MockedVaultService())
        with pytest.raises(RabbitConnectorCrdDoesNotExist):
            rabbit_connector_service.on_create_deployment(ms_rabbit_con=ms_rabbit_con)

    def test_on_create_deployment_no_rabbit_in_crds(self, mocker):
        rabbit_connector = RabbitConnector(
            broker_host="rabbit.default",
            broker_port=5672,
            url="https://rabbit.local",
            username="vault:secret/data/non-exist-secret#USERNAME",
            password="vault:secret/data/non-exist-secret#PASSWORD",
        )
        KubernetesServiceMocker.mock_get_rabbit_connector(mocker=mocker, rabbit_connector=rabbit_connector)
        ms_rabbit_con = RabbitConnectorMicroserviceDtoTestFactory()
        rabbit_connector_service = RabbitConnectorService(vault_service=MockedVaultService())
        with pytest.raises(UnknownVaultPathInRabbitConnector):
            rabbit_connector_service.on_create_deployment(ms_rabbit_con=ms_rabbit_con)

    def test_on_create_deployment(self, mocker):
        rabbit_api_cred: RabbitApiSecretDto = RabbitApiSecretDtoTestFactory()
        ms_rabbit_con: RabbitConnectorMicroserviceDto = RabbitConnectorMicroserviceDtoTestFactory()
        rabbit_connector = RabbitConnector(
            broker_host=rabbit_api_cred.broker_host,
            broker_port=rabbit_api_cred.broker_port,
            url=rabbit_api_cred.api_url,
            username=rabbit_api_cred.api_user,
            password=rabbit_api_cred.api_password,
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


@pytest.mark.unit
class TestRabbitConnectorValidationService:
    @pytest.fixture
    def vault(self):
        return MockedVaultClient(secret={
            "BROKER_HOST": "http://rabbit.local",
            "BROKER_PORT": "5672",
            "BROKER_USER": "username",
            "BROKER_PASSWORD": "password",
            "BROKER_VHOST": "rabbit",
            "BROKER_URL": f"amqp://username:password@rabbit.local:5672/rabbit",
        })

    @pytest.fixture
    def kube(self):
        return MockKubernetesService

    def test_annotation_contain_incorrect_vault_secret(self, kube, vault):
        annotations = {
            "rabbit.connector.itlabs.io/instance-name": "rabbit",
            "rabbit.connector.itlabs.io/vault-path": f"secret/data/rabbit",
            "rabbit.connector.itlabs.io/username": "rabbit",
            "rabbit.connector.itlabs.io/vhost": "rabbit",
        }
        labels = {}

        connector_dto = RabbitConnectorMicroserviceDtoFactory.dto_from_annotations(
            annotations, labels)
        service = RabbitConnectorValidationService(kube, vault)
        errors = service.validate(connector_dto)

        assert RabbitConnectorApplicationError(
            "Couldn't parse Vault secret path: secret/data/rabbit for RabbitMQ"
        ) in errors

    def test_vault_secret_not_contains_some_expected_keys(self, kube):
        annotations = {
            "rabbit.connector.itlabs.io/instance-name": "rabbit",
            "rabbit.connector.itlabs.io/vault-path": f"vault:secret/data/rabbit",
            "rabbit.connector.itlabs.io/username": "rabbit",
            "rabbit.connector.itlabs.io/vhost": "rabbit",
        }
        labels = {}

        vault = MockedVaultClient(secret={
            "BROKER_HOST": "http://rabbit.local",
            "BROKER_PORT": "5672",
            "BROKER_USER": "username",
            "BROKER_PASSWORD": "password",
            "BROKER_VHOST": "rabbit",
        })

        connector_dto = RabbitConnectorMicroserviceDtoFactory.dto_from_annotations(
            annotations, labels)
        service = RabbitConnectorValidationService(kube, vault)
        errors = service.validate(connector_dto)

        assert RabbitConnectorApplicationError(
            "Vault secret path for application doesn't contains next keys: "
            "BROKER_URL for RabbitMQ"
        ) in errors
