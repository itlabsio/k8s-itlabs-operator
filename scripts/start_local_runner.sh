#!/bin/sh

docker stop runner
docker stop postgres
docker stop vault-e2e
docker stop rabbitmq
docker container rm runner
docker container rm postgres
docker container rm vault-e2e
docker container rm rabbitmq

docker build -t operator -f e2e_tests/e2e.tests.Dockerfile .
docker run -v /var/run/docker.sock:/var/run/docker.sock --add-host=host.docker.internal:host-gateway --name=runner operator:latest