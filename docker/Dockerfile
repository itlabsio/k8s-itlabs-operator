FROM python:3.10.10-alpine3.17

WORKDIR /app

RUN apk add --no-cache bash gcc g++ musl-dev postgresql-dev libffi-dev \
    && pip install poetry

COPY poetry.lock pyproject.toml /app/
RUN poetry install

COPY k8s-itlabs-operator /app/

ENV PYTHONPATH "${PYTHONPATH}:/app"
