import logging

import hvac

from clients.vault import settings
from clients.vault.vaultclient import VaultClient, AbstractVaultClient

logger = logging.getLogger("vault_client")


class VaultClientFactory:
    @classmethod
    def create_vault_client(cls) -> AbstractVaultClient:
        with open('/var/run/secrets/kubernetes.io/serviceaccount/token') as f:
            jwt = f.read()
        role = settings.VAULT_K8S_ROLE
        client = hvac.Client(url=settings.VAULT_URL)
        client.token = client.auth.kubernetes.login(
            role, jwt, use_token=True, mount_point=settings.VAULT_K8S_AUTH_METHOD
        )['auth']['client_token']
        if not client.is_authenticated():
            logger.error("Vault auth failed ")
        return VaultClient(client)
