from hashlib import sha256
from typing import Union


def generate_hash(*args: Union[int, str]):
    if not args:
        raise AttributeError("No attributes to generate hash")

    if not all(isinstance(i, (int, str)) for i in args):
        raise TypeError("Arguments must be only int or str")

    text = "".join(str(i) for i in args)
    return sha256(text.encode("utf-8")).hexdigest()
