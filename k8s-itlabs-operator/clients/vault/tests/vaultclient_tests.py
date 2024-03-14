import pytest
from clients.vault.tests.mocks import VaultClientMocker
from clients.vault.vaultclient import VaultClient


@pytest.mark.unit
class TestVaultClient:
    def test_unvault_object(self, mocker):
        value = {"data": {"data": {"ASD": "greate_secret"}}}
        with VaultClientMocker.mock_hvac_vault_client(
            mocker, value
        ) as hvac_mocked:
            client = VaultClient(hvac_mocked)
            attr_dict = {
                "a": "vault",
                "b": "vault:mount/asd",
                "c": "vault:mount/data/asd",
                "d": "vault:mount/data/asd#ASD",
            }
            SimpleObject = type("SimpleObject", (object,), attr_dict)
            obj = SimpleObject()
            new_obj = client.unvault_object(obj)
            assert attr_dict.get("a") == new_obj.a
            assert attr_dict.get("b") == new_obj.b
            assert attr_dict.get("c") == new_obj.c
            assert attr_dict.get("d") != new_obj.d
            assert value["data"]["data"]["ASD"] == new_obj.d
