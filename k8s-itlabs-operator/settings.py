from os import getenv

ENVIRONMENT = getenv("ENVIRONMENT", "development")
OPERATOR_NAMESPACE = getenv("OPERATOR_NAMESPACE", "k8s-itlabs-operator")
KUBERNETES_LOCAL_CONTEXT = getenv("KUBENETES_LOCAL_CONTEXT", "docker-desktop")

# Admission webhook server settings
AWH_PORT = getenv("AWH_PORT", 9443)
AWH_ADDR = getenv("AWH_ADDR", '0.0.0.0')
AWH_HOST = getenv("AWH_HOST") if getenv("AWH_HOST") else getenv("AWH_ADDR", 'host.docker.internal')

CLUSTER_NAME = getenv("CLUSTER_NAME", "unknown")
SENTRY_DSN = getenv("SENTRY_DSN")

LOG_LEVEL = getenv("LOG_LEVEL", "DEBUG")
