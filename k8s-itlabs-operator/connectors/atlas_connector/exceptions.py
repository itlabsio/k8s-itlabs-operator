from typing import Optional

from connectors.atlas_connector import specifications


class AtlasConfigMapException(Exception):
    def __init__(self, key: Optional[str] = None):
        if key:
            message = f"In configmap {specifications.CONFIGMAP_NAME} does not exist key {key}"
        else:
            message = f"In configmap {specifications.CONFIGMAP_NAME} does not exist data"
        super().__init__(message)


class AtlasAnnotationsEmptyValueException(Exception):
    def __init__(self, annotation_name: str):
        message = f"Get annotation '{annotation_name}' but value is empty"
        super().__init__(message)


class AtlasAnnotationsGitlabProjectIdValueException(Exception):
    def __init__(self, id_str: str, ex: Exception):
        message = (
            f"Get annotation '{specifications.ANNOTATION_CI_PROJECT_ID},"
            f" but received value is non-digital: '{id_str}'"
        )
        super().__init__(message, ex.args)
