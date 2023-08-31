import abc
from typing import List, Any


class ConnectorError(Exception):
    def __eq__(self, other: Any) -> bool:
        if isinstance(other, ConnectorError):
            return str(self) == str(other)
        return False


class ConnectorValidationService(abc.ABC):
    @abc.abstractmethod
    def __init__(self):
        self.errors: List[ConnectorError] = []

    @abc.abstractmethod
    def validate(self, *args, **kwargs) -> List[ConnectorError] | None:
        raise NotImplementedError
