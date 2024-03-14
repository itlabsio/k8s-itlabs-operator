import pytest
from clients.sentry.dto import SentryProjectKey
from clients.sentry.tests.mocks import MockedSentryClient
from clients.vault.tests.mocks import MockedVaultClient
from connectors.sentry_connector import specifications
from connectors.sentry_connector.dto import SentryConnector
from connectors.sentry_connector.exceptions import (
    NonExistSecretForSentryConnector,
    SentryConnectorCrdDoesNotExist,
)
from connectors.sentry_connector.factories.dto_factory import (
    SentryConnectorMicroserviceDtoFactory,
)
from connectors.sentry_connector.services.kubernetes import KubernetesService
from connectors.sentry_connector.services.sentry import SentryService
from connectors.sentry_connector.services.sentry_connector import (
    SentryConnectorService,
)
from connectors.sentry_connector.services.validation import (
    SentryConnectorApplicationError,
    SentryConnectorValidationService,
)
from connectors.sentry_connector.services.vault import VaultService
from connectors.sentry_connector.tests.factories import (
    SentryConnectorMicroserviceDtoTestFactory,
)
from connectors.sentry_connector.tests.mocks import (
    KubernetesServiceMocker,
    MockedVaultService,
    MockKubernetesService,
)


@pytest.mark.unit
class TestVaultService:

    def test_get_vault_env_value(self):
        vault_client = MockedVaultClient()
        vault_service = VaultService(vault_client=vault_client)
        vault_path = "vault:secret/data/path"
        vault_key = "key"
        vault_value = vault_service.get_vault_env_value(
            vault_path=vault_path, vault_key=vault_key
        )
        assert vault_value == f"{vault_path}#{vault_key}"


@pytest.mark.unit
class TestKubernetesService:

    def test_get_pod_annotations(self):
        annotations = {"key": "value"}
        meta = {"annotations": annotations}

        pod_annotations = KubernetesService.get_pod_annotations(meta)
        assert isinstance(pod_annotations, dict)
        assert annotations == pod_annotations

    def test_get_pod_labels(self):
        labels = {"key": "value"}
        meta = {"labels": labels}

        pod_labels = KubernetesService.get_pod_labels(meta)
        assert isinstance(pod_labels, dict)
        assert labels == pod_labels


@pytest.mark.unit
class TestSentryService:

    def test_is_sentry_dsn_exist(self):
        sentry_client = MockedSentryClient(
            project_key=SentryProjectKey(name="sentry", dsn="dsn://sentry")
        )
        sentry_service = SentryService(sentry_client=sentry_client)
        assert sentry_service.is_sentry_dsn_exist(
            project_slug="application", dsn="dsn://sentry"
        )


@pytest.mark.unit
class TestSentryConnectorService:

    def test_sentry_connector_used_by_object(self):
        annotations = {
            specifications.SENTRY_INSTANCE_NAME_ANNOTATION: "sentry",
            specifications.SENTRY_VAULT_PATH_ANNOTATION: "vault:secret/data/application",
            specifications.SENTRY_ENVIRONMENT_ANNOTATION: "development",
        }
        labels = {
            specifications.SENTRY_APP_NAME_LABEL: "application",
        }
        assert SentryConnectorService.is_sentry_conn_used_by_object(
            annotations, labels
        )

    def test_on_create_deployment_no_sentry_conn_crd(self, mocker):
        KubernetesServiceMocker.mock_get_sentry_connector(mocker)
        sentry_conn_service = SentryConnectorService(
            vault_service=MockedVaultService()
        )
        ms_sentry_conn = SentryConnectorMicroserviceDtoTestFactory()
        with pytest.raises(SentryConnectorCrdDoesNotExist):
            sentry_conn_service.on_create_deployment(ms_sentry_conn)

    def test_on_create_deployment_no_exist_sentry_instance_secret(self, mocker):
        sentry_conn = SentryConnector(
            url="https://sentry.local",
            token="vault:secret/data/sentry#API_TOKEN",
            organization="sentry",
        )
        KubernetesServiceMocker.mock_get_sentry_connector(
            mocker, sentry_connector=sentry_conn
        )
        sentry_conn_service = SentryConnectorService(
            vault_service=MockedVaultService()
        )
        ms_sentry_conn = SentryConnectorMicroserviceDtoTestFactory()
        with pytest.raises(NonExistSecretForSentryConnector):
            sentry_conn_service.on_create_deployment(ms_sentry_conn)

    def test_mutate_container_variables_already_in_container(self):
        sentry_conn_service = SentryConnectorService(
            vault_service=MockedVaultService()
        )
        ms_sentry_conn = SentryConnectorMicroserviceDtoTestFactory()
        spec = {
            "containers": [
                {
                    "name": "application",
                    "env": [
                        {"name": var_name, "value": "value"}
                        for var_name, _ in specifications.SENTRY_VAR_NAMES
                    ],
                }
            ]
        }
        assert not sentry_conn_service.mutate_containers(
            spec=spec, ms_sentry_conn=ms_sentry_conn
        )

    def test_mutate_container_variables_not_in_container(self):
        sentry_conn_service = SentryConnectorService(
            vault_service=MockedVaultService()
        )
        ms_sentry_conn = SentryConnectorMicroserviceDtoTestFactory()
        spec = {
            "initContainers": [{"name": "init-container"}],
            "containers": [{"name": "container"}],
        }
        assert sentry_conn_service.mutate_containers(
            spec=spec, ms_sentry_conn=ms_sentry_conn
        )


@pytest.mark.unit
class TestSentryConnectorValidationService:
    @pytest.fixture
    def vault(self):
        return MockedVaultClient(
            secret={
                "SENTRY_DSN": "https://00000000000000000000000000000000@sentry/1",
                "SENTRY_PROJECT_SLUG": "sentry",
            }
        )

    @pytest.fixture
    def kube(self):
        return MockKubernetesService()

    def test_annotation_contain_incorrect_vault_secret(self, kube, vault):
        annotations = {
            "sentry.connector.itlabs.io/instance-name": "sentry",
            "sentry.connector.itlabs.io/vault-path": "secret/data/sentry",
            "sentry.connector.itlabs.io/environment": "test",
            "sentry.connector.itlabs.io/project": "project",
            "sentry.connector.itlabs.io/team": "team",
        }
        labels = {}

        connector_dto = (
            SentryConnectorMicroserviceDtoFactory.dto_from_annotations(
                annotations, labels
            )
        )
        service = SentryConnectorValidationService(kube, vault)
        errors = service.validate(connector_dto)

        assert (
            SentryConnectorApplicationError(
                "Couldn't parse Vault secret path: secret/data/sentry for Sentry"
            )
            in errors
        )

    def test_vault_secret_not_contains_some_expected_keys(self, kube):
        annotations = {
            "sentry.connector.itlabs.io/instance-name": "sentry",
            "sentry.connector.itlabs.io/vault-path": "vault:secret/data/sentry",
            "sentry.connector.itlabs.io/environment": "test",
            "sentry.connector.itlabs.io/project": "project",
            "sentry.connector.itlabs.io/team": "team",
        }
        labels = {}

        vault = MockedVaultClient(
            secret={
                "SENTRY_PROJECT_SLUG": "sentry",
            }
        )

        connector_dto = (
            SentryConnectorMicroserviceDtoFactory.dto_from_annotations(
                annotations, labels
            )
        )
        service = SentryConnectorValidationService(kube, vault)
        errors = service.validate(connector_dto)

        assert (
            SentryConnectorApplicationError(
                "Vault secret path for application doesn't contains next keys: "
                "SENTRY_DSN for Sentry"
            )
            in errors
        )
