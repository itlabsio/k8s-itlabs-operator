#!/bin/sh

curl -f http://vault:8200/v1/sys/health \
  && curl -f http://keycloak:8080/health/ready \
  && curl -f http://sentry:9000/_health/
