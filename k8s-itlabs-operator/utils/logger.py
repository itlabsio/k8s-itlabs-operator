import logging
from typing import Union


def get_level(level: Union[int, str]) -> int:
    if isinstance(level, str) and level.isdigit():
        level = int(level)

    level_name = (logging.getLevelName(level) if isinstance(level, int) else level).upper()
    level_val = getattr(logging, level_name, None)
    if not isinstance(level_val, int):
        raise ValueError("Not a valid log level.")
    return level_val
