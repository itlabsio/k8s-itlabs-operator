from dataclasses import dataclass


@dataclass
class SecretContextDto:
    service_name: str
    location_vault_path: str


@dataclass
class SecretDto:
    secret_path: str
    vault_data: dict
