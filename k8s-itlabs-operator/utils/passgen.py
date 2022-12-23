import random

DEFAULT_PASSWORD_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjklmnpqrstuvwxyz23456789"


def generate_password(length: int = 15, chars: str = DEFAULT_PASSWORD_CHARS) -> str:
    """
    Generate random password with set length using chars.
    """
    if not isinstance(length, int) or length <= 0:
        raise ValueError(f"Password length couldn't less or equal than zero '{length}'")

    if not isinstance(chars, str) or len(chars) == 0:
        raise ValueError("String of chars to generate password couldn't be empty")

    return ''.join(random.SystemRandom().choice(chars) for _ in range(length))
