from timeit import default_timer
from urllib.parse import urlparse

import wrapt
from kopf._cogs.clients import api
from observability.metrics.metrics import (
    app_http_request_operator_client_latency_seconds,
)


async def wrapper(wrapped, instance, args, kwargs):
    method = args[0] if args else kwargs.get("method")
    url = args[1] if args and len(args) > 1 else kwargs.get("url")
    context = args[6] if args and len(args) > 6 else kwargs.get("context")

    start_time = default_timer()
    if "://" not in url:
        uri = context.server if context else "unknown"
    else:
        parsed_uri = urlparse(url)
        uri = f"{parsed_uri.scheme}://{parsed_uri.netloc}/"

    label_values = {
        "uri": uri,
        "method": method,
        "status_code": "unknown",
        "exception_name": "unknown",
    }
    try:
        response = await wrapped(*args, **kwargs)
        label_values["status_code"] = response.status
        return response
    except Exception as e:
        label_values["exception_name"] = type(e).__name__
        raise
    finally:
        process_time = default_timer() - start_time
        app_http_request_operator_client_latency_seconds.labels(
            **label_values
        ).observe(process_time)


def wrap_request():
    wrapt.wrap_function_wrapper(api, "request", wrapper)
