from os import getenv

VAULT_URL = getenv("VAULT_URL", "http://localhost:8200")
VAULT_K8S_AUTH_METHOD = getenv("VAULT_K8S_AUTH_METHOD", "kube-dev")
VAULT_K8S_ROLE = getenv("VAULT_K8S_ROLE", "k8s-itlabs-operator")
VAULT_KV_MOUNT_POINT = getenv("VAULT_KV_MOUNT_POINT", "secret")
