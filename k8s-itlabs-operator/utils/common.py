import urllib.parse
from dataclasses import dataclass
from typing import Optional

import ujson
from kubernetes import client as kube_client


class WrappedObj:
    def __init__(self, data):
        self.data = data


def deserialize_dict_to_kubeobj(d: dict, kubeobjclass):
    kube_api = kube_client.ApiClient()
    wrapped_obj = WrappedObj(data=ujson.dumps(d))
    return kube_api.deserialize(wrapped_obj, kubeobjclass)


@dataclass
class OwnerReferenceDto:
    kind: str
    name: str


class OwnerReferenceDtoFactory:
    @staticmethod
    def dto_from_dict(owner: dict) -> Optional[OwnerReferenceDto]:
        try:
            return OwnerReferenceDto(
                kind=owner["kind"],
                name=owner["name"],
            )
        except IndexError:
            return None


def get_owner_reference(body: dict) -> Optional[OwnerReferenceDto]:
    try:
        owner = body.get("metadata", {}).get("ownerReferences", [])[0]
        return OwnerReferenceDtoFactory.dto_from_dict(owner)
    except IndexError:
        return None


def join(base: str, url: str):
    if not base.endswith("/"):
        base += "/"

    return urllib.parse.urljoin(base, url)


def strtobool(val):
    """Convert a string representation of truth to true (1) or false (0).

    True values are 'y', 'yes', 't', 'true', 'on', and '1'; false values
    are 'n', 'no', 'f', 'false', 'off', and '0'.  Raises ValueError if
    'val' is anything else.
    """
    val = val.lower()
    if val in ("y", "yes", "t", "true", "on", "1"):
        return 1
    if val in ("n", "no", "f", "false", "off", "0"):
        return 0
    raise ValueError(f"invalid truth value {val}")
