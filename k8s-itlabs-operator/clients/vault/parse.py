import re
from collections import namedtuple

import hvac

from clients.vault.specifications import VAULT_SCHEME

SecretPathParseResult = namedtuple("VaultParseResult", "mount_point, path")

VaultPath = namedtuple("VaultPath", "mount_point, path, key")


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


def parse_vault_path(vault_path: str) -> VaultPath:
    """
    Parse vault path to secret

    Vault secret path scheme:
        vault:{mount_point}/data/{path}[#KEY]

    Example:
        >>> parse_vault_path('vault:secret/data/application/postgres')
        VaultPath(mount_point='secret', path='application/postgres', key=None)

        >>> parse_vault_path('vault:secret/data/application/postgres#HOST')
        VaultPath(mount_point='secret', path='application/postgres', key='HOST')
    """

    scheme = r"vault"
    mount_point = r"(?P<mount_point>\w+)"
    path = r"(?P<path>\w+(/\w+)+)"
    key = r"(?P<key>\w+)"

    regex = f"^{scheme}:{mount_point}/data/{path}(#{key})?$"
    match = re.match(regex, vault_path)
    if match is None:
        raise hvac.v1.exceptions.InvalidPath("Invalid vault path scheme")
    return VaultPath(**match.groupdict())
