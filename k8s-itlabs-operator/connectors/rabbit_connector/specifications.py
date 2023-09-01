RABBIT_API_URL_KEY = 'API_URL'
RABBIT_API_USER_KEY = 'API_USER'
RABBIT_API_PASSWORD_KEY = 'API_PASSWORD'
RABBIT_BROKER_HOST_KEY = 'BROKER_HOST'
RABBIT_BROKER_PORT_KEY = 'BROKER_PORT'

RABBIT_BROKER_USER_KEY = 'BROKER_USER'
RABBIT_BROKER_PASSWORD_KEY = 'BROKER_PASSWORD'
RABBIT_BROKER_VHOST_KEY = 'BROKER_VHOST'
RABBIT_BROKER_URL_KEY = 'BROKER_URL'

RABBIT_VAR_NAMES = (
    ('BROKER_HOST', RABBIT_BROKER_HOST_KEY),
    ('BROKER_PORT', RABBIT_BROKER_PORT_KEY),
    ('BROKER_LOGIN', RABBIT_BROKER_USER_KEY),
    ('BROKER_PASSWORD', RABBIT_BROKER_PASSWORD_KEY),
    ('BROKER_VHOST', RABBIT_BROKER_VHOST_KEY),
    ('BROKER_URL', RABBIT_BROKER_URL_KEY),
)

RABBIT_INSTANCE_NAME_ANNOTATION = 'rabbit.connector.itlabs.io/instance-name'
VAULTPATH_NAME_ANNOTATION = 'rabbit.connector.itlabs.io/vault-path'
USER_NAME_ANNOTATION = 'rabbit.connector.itlabs.io/username'
VHOST_NAME_ANNOTATION = 'rabbit.connector.itlabs.io/vhost'

RABBIT_CONNECTOR_REQUIRED_ANNOTATIONS = (
    RABBIT_INSTANCE_NAME_ANNOTATION,
    VAULTPATH_NAME_ANNOTATION,
)

REQUIRED_RABBIT_SECRET_KEYS = (
    RABBIT_BROKER_HOST_KEY,
    RABBIT_BROKER_PORT_KEY,
    RABBIT_BROKER_USER_KEY,
    RABBIT_BROKER_PASSWORD_KEY,
    RABBIT_BROKER_VHOST_KEY,
    RABBIT_BROKER_URL_KEY,
)

APP_NAME_LABEL = 'app'
