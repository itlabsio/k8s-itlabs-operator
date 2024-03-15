from dataclasses import dataclass
from enum import Enum
from typing import Optional


class EnabledLabelValues(str, Enum):
    undefined = "undefined"
    enabled = "enabled"
    disabled = "disabled"

    def __str__(self) -> str:
        return str(self.value)


class UsedLabelValues(str, Enum):
    undefined = "undefined"
    used = "used"
    unused = "unused"

    def __str__(self) -> str:
        return str(self.value)


class SuccessLabelValues(str, Enum):
    undefined = "undefined"
    success = "success"
    failure = "failure"


@dataclass
class ConnectorStatus:
    is_enabled: Optional[bool] = None
    is_used: Optional[bool] = None
    exception: Optional[Exception] = None

    @property
    def label_is_enabled(self) -> str:
        if self.is_enabled is None:
            label_value = EnabledLabelValues.undefined
        elif self.is_enabled:
            label_value = EnabledLabelValues.enabled
        else:
            label_value = EnabledLabelValues.disabled
        return str(label_value)

    @property
    def label_is_used(self) -> str:
        if self.is_used is None:
            label_value = UsedLabelValues.undefined
        elif self.is_used:
            label_value = UsedLabelValues.used
        else:
            label_value = UsedLabelValues.unused
        return str(label_value)

    @property
    def label_exception(self) -> str:
        exception_str = ""
        if self.exception:
            module = self.exception.__class__.__module__
            if module is None or module == str.__class__.__module__:
                exception_str = self.exception.__class__.__name__
            else:
                exception_str = module + "." + self.exception.__class__.__name__
        return exception_str


@dataclass
class MutationHookStatus:
    is_used: Optional[bool] = None
    is_success: Optional[bool] = None
    owner: Optional[str] = None

    @property
    def label_is_used(self) -> str:
        if self.is_used is None:
            label_value = UsedLabelValues.undefined
        elif self.is_used:
            label_value = UsedLabelValues.used
        else:
            label_value = UsedLabelValues.unused
        return str(label_value)

    @property
    def label_is_success(self) -> str:
        if self.is_success is None:
            label_value = SuccessLabelValues.undefined
        elif self.is_success:
            label_value = SuccessLabelValues.success
        else:
            label_value = SuccessLabelValues.failure
        return str(label_value)

    @property
    def label_owner(self) -> str:
        if self.owner is None:
            return ""
        return self.owner
