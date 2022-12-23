FROM python:3.8.15-alpine3.16

WORKDIR /app

RUN apk add --no-cache bash gcc g++ musl-dev postgresql-dev libffi-dev \
    && pip install poetry

COPY poetry.lock pyproject.toml /app/
RUN poetry install

COPY k8s-itlabs-operator /app/

ENV PYTHONPATH "${PYTHONPATH}:/app"
