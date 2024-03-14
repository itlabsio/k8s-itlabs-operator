from os import getenv

SENTRY_TIMEOUT = 10
SENTRY_TOKEN = getenv("SENTRY_TOKEN", "")
SENTRY_ORGANIZATION = getenv("SENTRY_ORGANIZATION", "sentry")
