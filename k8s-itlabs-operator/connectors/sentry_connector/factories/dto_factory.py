from connectors.sentry_connector import specifications
from connectors.sentry_connector.crd import SentryConnectorCrd
from connectors.sentry_connector.dto import (
    SentryApiSecretDto,
    SentryConnector,
    SentryConnectorMicroserviceDto,
    SentryMsSecretDto,
)
from connectors.sentry_connector.exceptions import (
    SentryConnectorAnnotationEmptyValueError,
    SentryConnectorMissingRequiredAnnotationError,
)
from validation.annotations_validator import AnnotationValidator


class SentryMsSecretDtoFactory:
    @staticmethod
    def dto_from_dict(data: dict) -> SentryMsSecretDto:
        return SentryMsSecretDto(
            dsn=data.get(specifications.SENTRY_DSN_KEY),
            project_slug=data.get(specifications.SENTRY_PROJECT_SLUG_KEY),
        )

    @staticmethod
    def dict_from_dto(sentry_ms_cred: SentryMsSecretDto) -> dict:
        return {
            specifications.SENTRY_DSN_KEY: sentry_ms_cred.dsn,
            specifications.SENTRY_PROJECT_SLUG_KEY: sentry_ms_cred.project_slug,
        }


class SentryConnectorFactory:
    @staticmethod
    def dto_from_sentry_connector_crd(
        sentry_connector_crd: SentryConnectorCrd,
    ) -> SentryConnector:
        return SentryConnector(
            url=sentry_connector_crd.spec.url,
            token=sentry_connector_crd.spec.token,
            organization=sentry_connector_crd.spec.organization,
        )


class SentryAnnotationValidator(AnnotationValidator):
    required_annotation_names = (
        specifications.SENTRY_CONNECTOR_REQUIRED_ANNOTATIONS
    )
    on_missing_required_annotation_error = (
        SentryConnectorMissingRequiredAnnotationError
    )
    not_empty_annotation_names = specifications.SENTRY_CONNECTOR_ANNOTATIONS
    on_empty_value_annotation_error = SentryConnectorAnnotationEmptyValueError


class SentryConnectorMicroserviceDtoFactory:
    @classmethod
    def dto_from_annotations(
        cls, annotations: dict, labels: dict
    ) -> SentryConnectorMicroserviceDto:
        sentry_annotations = {}
        default_name = labels.get(specifications.SENTRY_APP_NAME_LABEL)
        default_environment = "default"
        for key in specifications.SENTRY_CONNECTOR_ANNOTATIONS:
            if key == specifications.SENTRY_PROJECT_ANNOTATION:
                sentry_annotations[key] = annotations.get(
                    specifications.SENTRY_PROJECT_ANNOTATION, default_name
                )
            if key == specifications.SENTRY_TEAM_ANNOTATION:
                sentry_annotations[key] = annotations.get(
                    specifications.SENTRY_TEAM_ANNOTATION, default_name
                )
            if key == specifications.SENTRY_ENVIRONMENT_ANNOTATION:
                sentry_annotations[key] = cls._parse_environment(
                    annotations.get(
                        specifications.SENTRY_ENVIRONMENT_ANNOTATION,
                        default_environment,
                    )
                )
            elif key in annotations:
                sentry_annotations[key] = annotations[key]
        SentryAnnotationValidator.validate(sentry_annotations)
        return SentryConnectorMicroserviceDto(
            sentry_instance_name=sentry_annotations.get(
                specifications.SENTRY_INSTANCE_NAME_ANNOTATION
            ),
            vault_path=sentry_annotations.get(
                specifications.SENTRY_VAULT_PATH_ANNOTATION
            ),
            project=sentry_annotations.get(
                specifications.SENTRY_PROJECT_ANNOTATION
            ),
            team=sentry_annotations.get(specifications.SENTRY_TEAM_ANNOTATION),
            environment=sentry_annotations.get(
                specifications.SENTRY_ENVIRONMENT_ANNOTATION
            ),
        )

    @staticmethod
    def _parse_environment(env: str) -> str:
        """Возвращает сокращенное название среды окружения"""
        return specifications.SENTRY_TRANSFORM_ENVIRONMENTS.get(env, env)


class SentryApiSecretDtoFactory:
    @classmethod
    def api_secret_dto_from_connector(
        cls, sentry_connector: SentryConnector
    ) -> SentryApiSecretDto:
        return SentryApiSecretDto(
            api_url=sentry_connector.url,
            api_token=sentry_connector.token,
            api_organization=sentry_connector.organization,
        )
