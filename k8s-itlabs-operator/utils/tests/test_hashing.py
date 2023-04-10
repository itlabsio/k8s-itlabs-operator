import pytest

from utils.hashing import generate_hash


@pytest.mark.unit
class TestGenerateHashing:
    @pytest.mark.parametrize(
        "arguments, expected",
        (
            (
                ("postgres.local", 5432),
                "f71dd837fb04a6a8789ade158b0eb3b6e08a46dc7a6b244ae5ef831b0c269292"
            ),
            (
                ("postgres.local", "5432"),
                "f71dd837fb04a6a8789ade158b0eb3b6e08a46dc7a6b244ae5ef831b0c269292"
            ),
        )
    )
    def test_generate_hash(self, arguments, expected):
        assert generate_hash(*arguments) == expected

    def test_raises_attribute_error_on_empty_arguments(self):
        with pytest.raises(AttributeError, match="No attributes"):
            generate_hash()

    @pytest.mark.parametrize("error_type", (.5, [1, ], (2,), {3, }, {"k": 5}))
    def test_raises_type_error_on_incompatible_types(self, error_type):
        with pytest.raises(TypeError, match="must be only int or str"):
            generate_hash(error_type)
