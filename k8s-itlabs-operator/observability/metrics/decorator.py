from timeit import default_timer
from typing import Callable

from prometheus_client.context_managers import Timer
from prometheus_client.decorator import decorate

from observability.metrics.metrics import app_http_request_operator_latency_seconds
from operators.dto import ConnectorStatus


class LabeledTimer(Timer):
    def __init__(self, metric, callback_name, connector_type):
        super().__init__(metric, callback_name)
        self._connector_type = connector_type
        self._start = 0

    def _new_timer(self):
        return self.__class__(self._metric, self._callback_name, self._connector_type)

    def __enter__(self):
        self._start = default_timer()
        return self

    def __exit__(self, typ, value, traceback):
        # Time can go backwards.
        duration = max(default_timer() - self._start, 0)
        callback = getattr(self._metric, self._callback_name)
        callback(duration)

    def __call__(self, f):
        def wrapped(func, *args, **kwargs):
            # Obtaining new instance of timer every time
            # ensures thread safety and reentrancy.
            with self._new_timer() as timer:
                status = func(*args, **kwargs)
                label_values = {
                    'connector_type': self._connector_type,
                    'enabled': status.label_is_enabled,
                    'used': status.label_is_used,
                    'exception': status.label_exception
                }
                timer.labels(**label_values)
            connector_type_key = label_values.pop('connector_type')
            return {connector_type_key: label_values}

        return decorate(f, wrapped)


def connector_time(connector_type: str):
    return LabeledTimer(app_http_request_operator_latency_seconds, 'observe', connector_type)


def monitoring(connector_type: str):
    def wrap(func: Callable):
        def wrapped(*args, **kwargs):
            start_time = default_timer()
            status = ConnectorStatus()
            try:
                status = func(*args, **kwargs)
            except Exception as e:
                status.exception = e
                raise e
            finally:
                process_time = default_timer() - start_time
                label_values = {
                    'connector_type': connector_type,
                    'enabled': status.label_is_enabled,
                    'used': status.label_is_used,
                    'exception': status.label_exception
                }
                app_http_request_operator_latency_seconds.labels(**label_values).observe(process_time)
                connector_type_key = label_values.pop('connector_type')
                return {connector_type_key: label_values}

        return wrapped

    return wrap
