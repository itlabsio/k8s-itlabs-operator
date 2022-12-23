from kubernetes.client import V1ObjectMeta

from connectors.keycloak_connector.crd import KeycloakConnectorCrd, KeycloakConnectorSpec
from utils.common import deserialize_dict_to_kubeobj


class KeycloakConnectorCrdFactory:
    @classmethod
    def crd_from_dict(cls, crd: dict) -> KeycloakConnectorCrd:
        return KeycloakConnectorCrd(
            api_version=crd.get("apiVersion"),
            kind=crd.get("kind"),
            metadata=deserialize_dict_to_kubeobj(crd.get("metadata"), V1ObjectMeta),
            spec=cls._connector_spec_from_dict(crd.get("spec"))
        )

    @staticmethod
    def _connector_spec_from_dict(spec: dict) -> KeycloakConnectorSpec:
        return KeycloakConnectorSpec(
            url=spec.get("url"),
            realm=spec.get("realm"),
            username=spec.get("username"),
            password=spec.get("password"),
        )
