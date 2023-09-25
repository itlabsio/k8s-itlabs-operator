from kubernetes.client import V1ObjectMeta

from connectors.postgres_connector.crd import PostgresConnectorCrd, PostgresConnectorSpec
from utils.common import deserialize_dict_to_kubeobj


class PostgresConnectorCrdFactory:
    @classmethod
    def _connector_spec_from_dict(cls, spec: dict) -> PostgresConnectorSpec:
        return PostgresConnectorSpec(
            host=spec.get("host"),
            port=spec.get("port", 5432),
            database=spec.get("database", "postgres"),
            username=spec.get("username"),
            password=spec.get("password"),
            readonly_username=spec.get("readonly-username"),
        )

    @classmethod
    def crd_from_dict(cls, crd: dict) -> PostgresConnectorCrd:
        return PostgresConnectorCrd(
            api_version=crd.get("apiVersion"),
            kind=crd.get("kind"),
            metadata=deserialize_dict_to_kubeobj(crd.get("metadata"), V1ObjectMeta),
            spec=cls._connector_spec_from_dict(crd.get("spec")),
        )
