from typing import List, Type

from validation.exceptions import (
    AnnotationValidatorMissedRequiredException,
    AnnotationValidatorEmptyValueException
)


class AnnotationValidator:
    required_annotation_names: List[str]
    on_missing_required_annotation_error: Type[AnnotationValidatorMissedRequiredException]
    not_empty_annotation_names: List[str]
    on_empty_value_annotation_error: Type[AnnotationValidatorEmptyValueException]

    @classmethod
    def validate(cls, annotations: dict):
        annotation_names = [x for x in annotations if x in cls.not_empty_annotation_names]
        missed_annotation_names = [x for x in cls.required_annotation_names if x not in annotations]
        if missed_annotation_names:
            raise cls.on_missing_required_annotation_error(missed_annotation_names=missed_annotation_names)
        empty_annotation_names = [x for x in annotations if x in annotation_names and not annotations[x]]
        if empty_annotation_names:
            raise cls.on_empty_value_annotation_error(empty_annotation_names=empty_annotation_names)
