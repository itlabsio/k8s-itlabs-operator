import logging
from abc import ABCMeta, abstractmethod
from typing import Optional, TypeVar, Union

import hvac
from clients.vault.exceptions import IncorrectPath
from clients.vault.factories.vault_path import (
    CandidateVaultPathFactory,
    VaultPathFactory,
)
from clients.vault.vault_path import VaultPath
from exceptions import InfrastructureServiceProblem

AnyObject = TypeVar("AnyObject")
VaultValue = Union[
    int,
    str,
    bool,
    float,
    None,
    dict,
    list,
]
logger = logging.getLogger("vault_logger")


class AbstractVaultClient:
    __metaclass__ = ABCMeta

    @abstractmethod
    def read_secret(self, path: str) -> Optional[dict]:
        raise NotImplementedError

    @abstractmethod
    def create_secret(self, path: str, data: dict):
        raise NotImplementedError

    @abstractmethod
    def delete_secret(self, path: str):
        raise NotImplementedError

    @abstractmethod
    def unvault_object(self, obj: AnyObject) -> AnyObject:
        raise NotImplementedError


class VaultClient(AbstractVaultClient):
    _SECURED_VALUE = "******"
    _SECURED_KEYS = ["pass", "token", "dsn"]

    def __init__(self, hvac_vault_client: hvac.Client):
        self.client = hvac_vault_client

    def _get_secured_value(self, key: str, value: str) -> str:
        """
        Returns mask of key value if key is secured.
        """
        if (
            value
            and key
            and any(
                secured_key in key.lower() for secured_key in self._SECURED_KEYS
            )
        ):
            return self._SECURED_VALUE
        return value

    def _create_or_update_secret(
        self, vault_path: VaultPath, data: dict, update_allowed: bool = False
    ) -> dict:
        secured_data = {
            k: self._get_secured_value(k, v) for k, v in data.items()
        }
        logger.info(
            "Write secret '%(path)s' to Vault: %(data)s"
            % {"path": vault_path, "data": secured_data}
        )
        try:
            cas = None if update_allowed else 0
            result = self.client.secrets.kv.v2.create_or_update_secret(
                path=vault_path.path,
                secret=data,
                cas=cas,
                mount_point=vault_path.mount_point,
            )
            return result
        except Exception as e:
            raise InfrastructureServiceProblem("Vault", e)

    def _read_secret_version(self, vault_path: VaultPath) -> dict:
        """
        Get last secret version from Vault (kv2) by path /{mount_point}/data/{path}.
        """
        logger.info("Started reading Vault secret version: %s" % (vault_path,))
        result = None
        try:
            result = self.client.secrets.kv.v2.read_secret_version(
                path=vault_path.path, mount_point=vault_path.mount_point
            )
        except hvac.v1.exceptions.InvalidPath:
            logger.info(
                "Error while Read Vault secret version: %s - invalid path"
                % (vault_path,)
            )
        except Exception as e:
            raise InfrastructureServiceProblem("Vault", e)
        logger.info("Ended reading Vault secret version: %s" % (vault_path,))
        return result

    def _read_secret(self, vault_path: VaultPath) -> Optional[dict]:
        raw_response = self._read_secret_version(vault_path=vault_path)
        if raw_response:
            return raw_response["data"]["data"]
        return None

    def _read_secret_key(self, vault_path: VaultPath) -> Optional[VaultValue]:
        secret = self._read_secret(vault_path)
        if secret:
            return secret.get(vault_path.key, None)
        return None

    def read_secret(self, path: str) -> Optional[dict]:
        try:
            vault_path = VaultPathFactory.path_from_str(vault_path=path)
        except IncorrectPath as e:
            logger.info(e)
            return None
        return self._read_secret(vault_path=vault_path)

    def create_secret(self, path: str, data: dict):
        vault_path = VaultPathFactory.path_from_str(vault_path=path)
        self._create_or_update_secret(vault_path=vault_path, data=data)

    def delete_secret(self, path: str):
        try:
            logger.info("Delete secret '%s' from Vault" % (path,))
            vault_path = VaultPathFactory.path_from_str(vault_path=path)
            self.client.secrets.kv.v2.delete_metadata_and_all_versions(
                path=vault_path.path, mount_point=vault_path.mount_point
            )
        except Exception as e:
            raise InfrastructureServiceProblem("Vault", e)

    def unvault_object(self, obj: AnyObject) -> AnyObject:
        attrs = dir(obj)
        for attr in attrs:
            if isinstance(getattr(obj, attr), str):
                candidate_vault_path = (
                    CandidateVaultPathFactory.candidate_from_str(
                        vault_path=getattr(obj, attr)
                    )
                )
                if candidate_vault_path.is_vaulted_value:
                    value = self._read_secret_key(
                        candidate_vault_path.vault_path
                    )
                    setattr(obj, attr, value)
        return obj
