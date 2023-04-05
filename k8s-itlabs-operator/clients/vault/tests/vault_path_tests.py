import pytest

from clients.vault.factories.vault_path import CandidateVaultPathFactory


@pytest.mark.unit
class TestCandidateVaultPath:
    @pytest.mark.parametrize(
        "value, result",
        (
                ("vault:secret/data/postgres-credentials", False,),
                ("vault:secret/asd/postgres-credentials#KEY", False,),
                ("vault:secret/data/postgres-credentials#KEY", True,),
                ("vaultsecret/data/postgres-credentials#KEY", False,),
        )
    )
    def test_is_vaulted_value(self, value, result):
        vault_path = CandidateVaultPathFactory.candidate_from_str(vault_path=value)
        assert vault_path.is_vaulted_value == result
