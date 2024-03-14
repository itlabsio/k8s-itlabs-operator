import pytest
from utils.common import OwnerReferenceDto, get_owner_reference


@pytest.mark.unit
class TestGettingOwnerName:

    def test_getting_first_owner(self):
        body = {
            "metadata": {
                "ownerReferences": [
                    {
                        "kind": "ReplicaSet",
                        "name": "firstOwner",
                    },
                    {
                        "kind": "ReplicaSet",
                        "name": "secondOwner",
                    },
                ]
            }
        }

        assert get_owner_reference(body) == OwnerReferenceDto(
            kind="ReplicaSet", name="firstOwner"
        )

    def test_return_none_on_empty_owner_references(self):
        body = {"metadata": {"ownerReferences": []}}

        assert get_owner_reference(body) is None

    def test_return_none_on_empty_body(self):
        body = {}
        assert get_owner_reference(body) is None
