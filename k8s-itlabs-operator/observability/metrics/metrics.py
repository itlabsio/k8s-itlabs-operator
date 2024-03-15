from prometheus_client import Gauge, Histogram
from prometheus_client.utils import INF

app_http_request_operator_latency_seconds = Histogram(
    name="app_http_request_operator_latency_seconds",
    documentation="Данная метрика содержит количество запросов в значении, разделенное на интервалы "
    "[0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 0.75, 1.0, 2.5, 5.0, 7.5, 10.0, +Inf]. "
    "Метка connector_type ДОЛЖНА содержать тип коннектрора (postgres, rabbit, sentry, monitoring), "
    "метка enabled ДОЛЖНА содержать информацию включен ли коннектор (по признакам, специфичным для "
    "каждого коннектора) или нет (true, false), "
    "метка used ДОЛЖНА содержать информацию отработал ли коннектор или была просто "
    "проверка (true, false), "
    "Метка exception МОЖЕТ содержать тип ошибки при обработке, если такая возникла",
    labelnames=("connector_type", "enabled", "used", "exception"),
    buckets=(
        0.005,
        0.01,
        0.025,
        0.05,
        0.075,
        0.1,
        0.25,
        0.5,
        0.75,
        1.0,
        2.5,
        5.0,
        7.5,
        10.0,
        INF,
    ),
)

app_up = Gauge("app_up", "service", labelnames=("application",))

app_http_request_operator_client_latency_seconds = Histogram(
    name="app_http_request_operator_client_latency_seconds",
    documentation="Данная метрика содержит количество исходящих запросов в значении, разделенное на интервалы "
    "[0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 0.75, 1.0, 2.5, 5.0, 7.5, 10.0, +Inf]. "
    "Метка uri ДОЛЖНА содержать относительный URI для маршрута, для которого "
    "собирается метрика. Метка status_code ДОЛЖНА содержать код HTTP статуса запроса. "
    "Метка method ДОЛЖНА содержать название HTTP метода, который данный запрос исполнил. "
    "В метке exception_name СЛЕДУЕТ содержать название возбужденного исключения, "
    "которое прервало успешное исполнение обработчика текущего запроса по тем "
    "или иным причинам (оно МОЖЕТ совпадать с названием класса исключения). Примечание: обратите внимание"
    ", что в списке обязательных меток не содержится метка le, которая и так является обязательной "
    "для histogram типа метрики.",
    labelnames=("uri", "status_code", "method", "exception_name"),
)

app_mutation_admission_hook_latency_seconds = Histogram(
    name="app_mutation_admission_hook_latency_seconds",
    documentation="Данная метрика содержит количество вызовов mutation hooks, разделенных на интервалы "
    "[0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 0.75, 1.0, 2.5, 5.0, 7.5, 10.0, +Inf]. "
    "Метка connector_type ДОЛЖНА содержать тип коннектора (postgres, rabbit, sentry, keycloak), "
    "метка used ДОЛЖНА содержать информацию о том, что должен был быть вызван коннектор или нет "
    "(по признакам специфичным для каждого коннектора), "
    "метка success ДОЛЖНА содержать значение о том, что был ли успешно выполнен коннектор, "
    "в метке owner СЛЕДУЕТ указать название родителя создаваемого ресурса.",
    labelnames=("connector_type", "used", "success", "owner"),
    buckets=(
        0.005,
        0.01,
        0.025,
        0.05,
        0.075,
        0.1,
        0.25,
        0.5,
        0.75,
        1.0,
        2.5,
        5.0,
        7.5,
        10.0,
        INF,
    ),
)
