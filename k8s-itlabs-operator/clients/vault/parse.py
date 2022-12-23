from collections import namedtuple

import hvac

from clients.vault.specifications import VAULT_SCHEME

SecretPathParseResult = namedtuple("VaultParseResult", "mount_point, path")


def parse_secret_path(secret_path: str) -> SecretPathParseResult:
    """
    Parse vault secret path.

    Vault secret path scheme:
        vault:{mount_point}/data/{path}

    Example:
        vault:secret/data/application/postgres-credentials
    """
    if not secret_path.startswith(VAULT_SCHEME):
        raise hvac.v1.exceptions.InvalidPath("Invalid vault path scheme")

    mount_point, *path = secret_path[len(f"{VAULT_SCHEME}:"):].split("/data/", maxsplit=1)
    if not (mount_point and path):
        raise hvac.v1.exceptions.InvalidPath("Invalid vault path")
    return SecretPathParseResult(mount_point=mount_point, path=path[0])
