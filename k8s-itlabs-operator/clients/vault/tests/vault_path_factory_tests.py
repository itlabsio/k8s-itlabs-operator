import pytest

from clients.vault.exceptions import IncorrectPath
from clients.vault.factories.vault_path import VaultPathFactory
from clients.vault.vault_path import VaultPath


@pytest.mark.unit
class TestVaultPathFactory:
    @pytest.mark.parametrize(
        "vault_path",
        (
                "application/postgres-credentials",
                "vault:data/application/postgres-credentials",
                "vault:secret/application/postgres-credentials",
        ),
    )
    def test_path_from_str_with_incorrect_path(self, vault_path):
        with pytest.raises(IncorrectPath):
            VaultPathFactory.path_from_str(vault_path=vault_path)


@pytest.mark.parametrize(
    "secret_path, expected",
    (
            (
                    "vault:secret/data/application/postgres-credentials",
                    VaultPath(
                        mount_point="secret",
                        path="application/postgres-credentials",
                        key=None
                    ),
            ),
            (
                    "vault:secret/data/application/postgres-credentials/data/asd",
                    VaultPath(
                        mount_point="secret",
                        path="application/postgres-credentials/data/asd",
                        key=None
                    ),
            ),
            (
                    "vault:secret/data/application/postgres-credentials#PASSWORD",
                    VaultPath(
                        mount_point="secret",
                        path="application/postgres-credentials",
                        key="PASSWORD"
                    )
            ),
    )
)
def test_parse_secret_path(secret_path, expected):
    assert VaultPathFactory.path_from_str(secret_path) == expected
