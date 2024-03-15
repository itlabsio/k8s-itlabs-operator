import datetime
import random

import kopf


@kopf.on.probe(id="now")
def get_current_timestamp(**kwargs):
    return datetime.datetime.utcnow().isoformat()


@kopf.on.probe(id="random")
def get_random_value(**kwargs):
    return random.randint(0, 1_000_000)
