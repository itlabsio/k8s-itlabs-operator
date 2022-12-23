from os import getenv

VAULT_TOKEN = getenv("OPERATOR_VAULT_TOKEN", "myroot")
VAULT_URL = getenv("VAULT_URL", "http://localhost:8200")
