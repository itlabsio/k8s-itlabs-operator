from clients.kubedeployer.specifications import ANNOTATION_CI_PROJECT_ID

CONFIGMAP_NAME = 'atlas-connector'

ATLAS_MICROSERVICE_NAME_ANNOTATION = 'atlas.connector.itlabs.io/microservice-name'
ATLAS_BUSINESS_NAME_ANNOTATION = 'atlas.connector.itlabs.io/business-name'

ATLAS_CON_REQUIRED_ANNOTATION_NAMES = (
    ATLAS_MICROSERVICE_NAME_ANNOTATION,
    ANNOTATION_CI_PROJECT_ID,
)

ATLAS_TOKEN_NAME_KEY = 'ATLAS_TOKEN'

# Atlas connector configmap keys
CONFIGMAP_CLUSTER_DNS_KEY = 'cluster-dns'
CONFIGMAP_ATLAS_URL_KEY = 'atlas-url'
CONFIGMAP_VAULT_PATH_KEY = 'vault-path'
