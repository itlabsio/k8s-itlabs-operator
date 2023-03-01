from collections import namedtuple

import hvac

from clients.vault.specifications import VAULT_SCHEME

VaultPathParseResult = namedtuple("VaultParseResult", "mount_point, path, key")


def parse_vault_path(vault_path: str) -> VaultPathParseResult:
    """
    Parse vault secret path.

    Vault secret path scheme:
        vault:{mount_point}/data/{path}

    Example:
        vault:secret/data/application/postgres-credentials
        vault:secret/data/application/postgres-credentials#PASSWORD
    """
    if not vault_path.startswith(VAULT_SCHEME):
        raise hvac.v1.exceptions.InvalidPath("Invalid vault path scheme")

    secret_path = vault_path[len(VAULT_SCHEME):]
    mount_point, *path = secret_path.split("/data/", maxsplit=1)
    if not (mount_point and path):
        raise hvac.v1.exceptions.InvalidPath("Invalid vault path")
    path = path[0]

    separator = "#"
    if separator not in path:
        return VaultPathParseResult(mount_point=mount_point, path=path, key=None)

    path, key = path.rsplit(separator, maxsplit=1)
    return VaultPathParseResult(mount_point=mount_point, path=path, key=key)
