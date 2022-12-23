from abc import ABCMeta, abstractmethod

from connectors.atlas_connector.specifications import ATLAS_TOKEN_NAME_KEY
from clients.vault.vaultclient import AbstractVaultClient


class AbstractVaultService:
    __metaclass__ = ABCMeta

    @abstractmethod
    def get_atlas_token(self, vault_path: str) -> str:
        raise NotImplementedError


class VaultService(AbstractVaultService):

    def __init__(self, vault_client: AbstractVaultClient):
        self.vault_client = vault_client

    def get_atlas_token(self, vault_path: str) -> str:
        vault_data = self.vault_client.read_secret_version_data(vault_path)
        return vault_data.get(ATLAS_TOKEN_NAME_KEY)
