from clients.vault.exceptions import IncorrectPath
from clients.vault.vault_path import CandidateVaultPath, VaultPath


class VaultPathFactory:
    @classmethod
    def path_from_str(cls, vault_path: str) -> VaultPath:
        """
        Parse vault secret path.

        Vault secret path scheme:
            vault:{mount_point}/data/{path}

        Example:
            vault:secret/data/application/postgres-credentials
            vault:secret/data/application/postgres-credentials#PASSWORD
        """
        if not vault_path.startswith(VaultPath.scheme):
            raise IncorrectPath(
                f"Invalid vault path scheme, it does not start with '{VaultPath.scheme}'"
            )

        secret_path = vault_path[len(VaultPath.scheme) :]
        mount_point, *path = secret_path.split(
            VaultPath.data_separator, maxsplit=1
        )
        if not (mount_point and path):
            raise IncorrectPath(
                f"Invalid vault path, could not correct split string "
                f"to mount_point and path with separator '{VaultPath.data_separator}'"
            )
        path = path[0]

        if VaultPath.key_separator not in path:
            key = None
        else:
            path, key = path.rsplit(VaultPath.key_separator, maxsplit=1)
        return VaultPath(mount_point=mount_point, path=path, key=key)


class CandidateVaultPathFactory:
    @classmethod
    def candidate_from_str(cls, vault_path: str) -> CandidateVaultPath:
        try:
            vault_path_obj = VaultPathFactory.path_from_str(
                vault_path=vault_path
            )
        except IncorrectPath:
            vault_path_obj = None
        return CandidateVaultPath(
            vault_path_str=vault_path, vault_path=vault_path_obj
        )
