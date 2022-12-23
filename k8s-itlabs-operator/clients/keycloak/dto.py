from dataclasses import dataclass
from typing import Optional


@dataclass
class Token:
    access_token: str


@dataclass
class ClientDto:
    client_id: str
    name: str
    protocol: str = "openid-connect"
    client_authenticator_type: str = "client-secret"
    id: Optional[str] = None


@dataclass
class Error:
    message: str
