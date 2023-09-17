from typing import List, Any


class ConnectorError(Exception):
    def __eq__(self, other: Any) -> bool:
        if isinstance(other, ConnectorError):
            return str(self) == str(other)
        return False


class AnnotationValidatorException(Exception):
    def __init__(self):
        super().__init__()
        self.message = "Invalid annotations"


class AnnotationValidatorMissedRequiredException(AnnotationValidatorException):
    def __init__(self, missed_annotation_names: List[str]):
        super().__init__()
        self.missed_annotation_names = missed_annotation_names
        annotations = ', '.join(missed_annotation_names)
        self.message = f"Missed required annotations: {annotations}"


class AnnotationValidatorEmptyValueException(AnnotationValidatorException):
    def __init__(self, empty_annotation_names: List[str]):
        super().__init__()
        self.empty_annotation_names = empty_annotation_names
        annotations = ', '.join(empty_annotation_names)
        self.message = f"Unaccessable empty value for annotations: {annotations}"
