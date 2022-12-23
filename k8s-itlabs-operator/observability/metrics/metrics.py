from prometheus_client import Histogram, Gauge
from prometheus_client.utils import INF

app_http_request_operator_latency_seconds = Histogram(
    name='app_http_request_operator_latency_seconds',
    documentation='Данная метрика содержит количество запросов в значении, разделенное на интервалы '
                  '[0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 0.75, 1.0, 2.5, 5.0, 7.5, 10.0, +Inf]. '
                  'Метка connector_type ДОЛЖНА содержать тип коннектрора (postgres, rabbit, sentry, monitoring), '
                  'метка enabled ДОЛЖНА содержать информацию включен ли коннектор (по признакам, специфичным для '
                  'каждого коннектора) или нет (true, false), '
                  'метка used ДОЛЖНА содержать информацию отработал ли коннектор или была просто '
                  'проверка (true, false), '
                  'Метка exception МОЖЕТ содержать тип ошибки при обработке, если такая возникла',
    labelnames=('connector_type', 'enabled', 'used', 'exception'),
    buckets=(.005, .01, .025, .05, .075, .1, .25, .5, .75, 1.0, 2.5, 5.0, 7.5, 10.0, INF)
)

app_up = Gauge('app_up', 'service', labelnames=('application',))

app_http_request_operator_client_latency_seconds = Histogram(
    name='app_http_request_operator_client_latency_seconds',
    documentation='Данная метрика содержит количество исходящих запросов в значении, разделенное на интервалы '
                  '[0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 0.75, 1.0, 2.5, 5.0, 7.5, 10.0, +Inf]. '
                  'Метка uri ДОЛЖНА содержать относительный URI для маршрута, для которого '
                  'собирается метрика. Метка status_code ДОЛЖНА содержать код HTTP статуса запроса. '
                  'Метка method ДОЛЖНА содержать название HTTP метода, который данный запрос исполнил. '
                  'В метке exception_name СЛЕДУЕТ содержать название возбужденного исключения, '
                  'которое прервало успешное исполнение обработчика текущего запроса по тем '
                  'или иным причинам (оно МОЖЕТ совпадать с названием класса исключения). Примечание: обратите внимание'
                  ', что в списке обязательных меток не содержится метка le, которая и так является обязательной '
                  'для histogram типа метрики.',
    labelnames=('uri', 'status_code', 'method', 'exception_name')
)
