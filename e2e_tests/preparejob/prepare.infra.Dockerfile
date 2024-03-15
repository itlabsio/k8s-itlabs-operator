from python:3.8-slim
WORKDIR /srv

RUN pip install hvac==1.0.2
RUN pip install kubernetes==25.3.0
RUN pip install psycopg2-binary==2.9.5

COPY e2e_tests/preparejob/prepare_infra.py prepare_infra.py

CMD python prepare_infra.py
