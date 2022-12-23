from kubernetes.client import V1ObjectMeta

from connectors.postgres_connector.crd import PostgresConnectorCrd, PostgresConnectorSpec
from utils.common import deserialize_dict_to_kubeobj


class PostgresConnectorCrdFactory:
    @classmethod
    def _connector_spec_from_dict(cls, spec_dict: dict) -> PostgresConnectorSpec:
        return PostgresConnectorSpec(
            name=spec_dict.get('name'),
            vaultpath=spec_dict.get('vaultpath')
        )

    @classmethod
    def crd_from_dict(cls, crd: dict) -> PostgresConnectorCrd:
        return PostgresConnectorCrd(
            api_version=crd.get('apiVersion'),
            kind=crd.get('kind'),
            metadata=deserialize_dict_to_kubeobj(crd.get('metadata'), V1ObjectMeta),
            spec=[cls._connector_spec_from_dict(spec) for spec in crd.get('spec')]
        )
