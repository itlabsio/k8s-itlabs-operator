import urllib.parse

import ujson
from kubernetes import client as kube_client


class WrappedObj:
    def __init__(self, data):
        self.data = data


def deserialize_dict_to_kubeobj(d: dict, kubeobjclass):
    kube_api = kube_client.ApiClient()
    wrapped_obj = WrappedObj(data=ujson.dumps(d))
    return kube_api.deserialize(wrapped_obj, kubeobjclass)


def join(base: str, url: str):
    if not base.endswith('/'):
        base += '/'

    return urllib.parse.urljoin(base, url)
