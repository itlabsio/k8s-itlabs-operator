import hvac
import pytest

from clients.vault.parse import SecretPathParseResult, parse_secret_path


@pytest.mark.parametrize(
    "secret_path, expected",
    (
            (
                "vault:secret/data/application/postgres-credentials",
                SecretPathParseResult(mount_point="secret", path="application/postgres-credentials"),
            ),
            (
                "vault:secret/data/application/postgres-credentials/data/asd",
                SecretPathParseResult(mount_point="secret", path="application/postgres-credentials/data/asd"),
            ),
    )
)
def test_parse_secret_path(secret_path, expected):
    assert parse_secret_path(secret_path) == expected


@pytest.mark.parametrize(
    "secret_path",
    (
            "application/postgres-credentials",
            "vault:data/application/postgres-credentials",
            "vault:secret/application/postgres-credentials",
    ),
)
def test_error_for_invalid_vault_path(secret_path):
    with pytest.raises(hvac.v1.exceptions.InvalidPath):
        parse_secret_path(secret_path)
