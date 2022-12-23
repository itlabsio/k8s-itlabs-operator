from copy import deepcopy
from typing import List

from clients.vault.vaultclient import AbstractVaultClient


class MockedVaultClient(AbstractVaultClient):
    def __init__(self, use_default_secret: bool = True, secret: dict = None):
        self.create_secret_call_count = 0
        self.write_path = None
        self.write_data = None
        if secret:
            self.secret = deepcopy(secret)
        else:
            self.secret = {"key": "value"} if use_default_secret else None

    def read_secret_version_data(self, path: str) -> dict:
        return self.secret

    def read_list_secrets_list(self, path: str) -> List[str]:
        pass

    def create_secret(self, path: str, data: dict):
        self.create_secret_call_count += 1
        self.write_path = path
        self.write_data = data

    def delete_secret_all_versions(self, path: str):
        pass

    def get_prefix_path(self):
        return 'vault:secret/data'
