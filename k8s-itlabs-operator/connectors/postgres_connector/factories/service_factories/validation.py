from clients.vault.factories.vault_client import VaultClientFactory
from connectors.postgres_connector.dto import PgConnectorInstanceSecretDto
from connectors.postgres_connector.factories.service_factories.postgres import \
    PostgresServiceFactory
from connectors.postgres_connector.services.kubernetes import KubernetesService
from connectors.postgres_connector.services.validation import PostgresConnectorValidationService


class PostgresConnectorValidationServiceFactory:
    @staticmethod
    def create(pg_instance_cred: PgConnectorInstanceSecretDto) -> PostgresConnectorValidationService:
        return PostgresConnectorValidationService(
            vault_client=VaultClientFactory.create_vault_client(),
            kube_service=KubernetesService(),
            postgres_service=PostgresServiceFactory.create_pg_service(pg_instance_cred),
        )
