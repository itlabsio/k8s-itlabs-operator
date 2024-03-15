from typing import Optional


class KubernetesClientMocker:
    @staticmethod
    def mock_get_configmap_data(mocker, data: Optional[dict] = None):
        if not data:
            data = {}
        mocker.patch(
            "clients.k8s.k8s_client.KubernetesClient.get_configmap_data",
            return_value=data,
        )
