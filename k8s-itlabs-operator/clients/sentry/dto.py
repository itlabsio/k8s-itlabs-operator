from dataclasses import dataclass
from typing import Optional


@dataclass
class SentryTeam:
    name: str
    slug: Optional[str]


@dataclass
class SentryProject:
    name: str
    slug: Optional[str]


@dataclass
class SentryProjectKey:
    name: str
    dsn: str
