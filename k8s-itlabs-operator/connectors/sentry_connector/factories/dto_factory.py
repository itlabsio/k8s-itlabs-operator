from connectors.sentry_connector import specifications
from connectors.sentry_connector.dto import SentryConnector, SentryMsSecretDto, \
    SentryConnectorMicroserviceDto
from connectors.sentry_connector.crd import SentryConnectorCrd
from connectors.sentry_connector.exceptions import EnvironmentValueError


class SentryMsSecretDtoFactory:
    @staticmethod
    def dto_from_dict(data: dict) -> SentryMsSecretDto:
        return SentryMsSecretDto(
            dsn=data.get(specifications.SENTRY_DSN_KEY),
            project_slug=data.get(specifications.SENTRY_PROJECT_SLUG_KEY),
        )

    @staticmethod
    def dict_from_dto(sentry_ms_creds: SentryMsSecretDto) -> dict:
        return {
            specifications.SENTRY_DSN_KEY: sentry_ms_creds.dsn,
            specifications.SENTRY_PROJECT_SLUG_KEY: sentry_ms_creds.project_slug,
        }


class SentryConnectorFactory:
    @staticmethod
    def dto_from_sentry_connector_crd(sentry_connector_crd: SentryConnectorCrd) -> SentryConnector:
        return SentryConnector(
            url=sentry_connector_crd.spec.url,
            token=sentry_connector_crd.spec.token,
            organization=sentry_connector_crd.spec.organization,
        )


class SentryConnectorMicroserviceDtoFactory:
    @classmethod
    def dto_from_annotations(cls, annotations: dict, labels: dict) -> SentryConnectorMicroserviceDto:
        default_team = labels.get(specifications.SENTRY_APP_NAME_LABEL)
        default_project = labels.get(specifications.SENTRY_APP_NAME_LABEL)
        return SentryConnectorMicroserviceDto(
            sentry_instance_name=annotations.get(specifications.SENTRY_INSTANCE_NAME_ANNOTATION),
            vault_path=annotations.get(specifications.SENTRY_VAULT_PATH_ANNOTATION),
            project=annotations.get(specifications.SENTRY_PROJECT_ANNOTATION, default_project),
            team=annotations.get(specifications.SENTRY_TEAM_ANNOTATION, default_team),
            environment=cls._parse_environment(annotations.get(specifications.SENTRY_ENVIRONMENT_ANNOTATION)),
        )

    @staticmethod
    def _parse_environment(env: str) -> str:
        """Возвращает сокращенное название среды окружения"""
        try:
            return specifications.SENTRY_AVAILABLE_ENVIRONMENTS[env].lower()
        except KeyError:
            raise EnvironmentValueError("Environment label contains invalid value")
