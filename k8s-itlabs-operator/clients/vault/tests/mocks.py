from copy import deepcopy
from typing import List, Optional

from clients.vault.vaultclient import AbstractVaultClient, AnyObject


class MockedVaultClient(AbstractVaultClient):
    def __init__(self, use_default_secret: bool = True, secret: dict = None):
        self.create_secret_call_count = 0
        self.write_path = None
        self.write_data = None
        if secret:
            self.secret = deepcopy(secret)
        else:
            self.secret = {"key": "value"} if use_default_secret else None

    def read_secret(self, path: str) -> dict:
        return self.secret

    def read_list_secrets_list(self, path: str) -> List[str]:
        pass

    def create_secret(self, path: str, data: dict):
        self.create_secret_call_count += 1
        self.write_path = path
        self.write_data = data

    def delete_secret(self, path: str):
        pass

    def read_secret_key(self, path: str) -> Optional[str]:
        pass

    def unvault_object(self, obj: AnyObject) -> AnyObject:
        pass


class VaultClientMocker:
    @staticmethod
    def mock_hvac_vault_client(mocker, value):
        return mocker.patch("clients.vault.vaultclient.VaultClient._read_secret_version", return_value=value)
