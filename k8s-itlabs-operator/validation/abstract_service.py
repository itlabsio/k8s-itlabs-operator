import abc
from typing import List

from validation.exceptions import ConnectorError


class ConnectorValidationService(abc.ABC):
    @abc.abstractmethod
    def __init__(self):
        self.errors: List[ConnectorError] = []

    @abc.abstractmethod
    def validate(self, *args, **kwargs) -> List[ConnectorError] | None:
        raise NotImplementedError
