from typing import Optional

from clients.vault import specifications


class VaultPathMeta(type):
    @property
    def scheme(cls):
        return getattr(cls, "_scheme")

    @property
    def data_separator(cls):
        return getattr(cls, "_data_separator")

    @property
    def key_separator(cls):
        return getattr(cls, "_key_separator")


class VaultPath(metaclass=VaultPathMeta):
    _scheme: str = specifications.VAULT_SCHEME
    _data_separator: str = specifications.DATA_SEPARATOR
    _key_separator: str = specifications.KEY_SEPARATOR
    _mount_point: Optional[str] = None
    _path: Optional[str] = None
    _key: Optional[str] = None

    def __init__(self, mount_point: str, path: str, key: Optional[str]):
        self._mount_point = mount_point
        self._path = path
        self._key = key

    @property
    def mount_point(self) -> str:
        return self._mount_point

    @property
    def path(self) -> str:
        return self._path

    @property
    def key(self) -> Optional[str]:
        return self._key

    @property
    def is_key_defined(self) -> bool:
        return bool(self.key)

    def __str__(self) -> str:
        vault_path = (
            f"{self._scheme}{self.mount_point}{self._data_separator}{self.path}"
        )
        if self.key:
            vault_path = f"{vault_path}{self._key_separator}{self.key}"
        return vault_path


class CandidateVaultPath:
    def __init__(self, vault_path_str: str, vault_path: Optional[VaultPath]):
        self._vault_path_str = vault_path_str
        self._vault_path = vault_path

    @property
    def is_correct_vaultpath(self) -> bool:
        return bool(self._vault_path)

    @property
    def is_vaulted_value(self) -> bool:
        return self.is_correct_vaultpath and self.vault_path.is_key_defined

    @property
    def vault_path(self) -> Optional[VaultPath]:
        return self._vault_path
