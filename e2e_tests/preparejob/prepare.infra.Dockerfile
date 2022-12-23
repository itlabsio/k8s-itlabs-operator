from python:3.8-slim
WORKDIR /srv

RUN pip install hvac==0.11.2
RUN pip install kubernetes==22.6.0
RUN pip install psycopg2-binary==2.9.3

COPY e2e_tests/preparejob/prepare_infra.py prepare_infra.py

CMD python prepare_infra.py