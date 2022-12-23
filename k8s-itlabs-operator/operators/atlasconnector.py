import logging

import kopf

from connectors.atlas_connector.factories.dto_factory import AtlasConnectorAnnotationsFactory
from connectors.atlas_connector.services.atlas_connector import AtlasConnectorService
from observability.metrics.decorator import monitoring


@kopf.on.create('pods.v1')
@kopf.on.update('pods.v1')
@monitoring(connector_type='atlas_connector')
def create_pods(annotations, namespace, **kwargs):
    logging.info("Atlas connector handler is called on pod creating/updating")
    """
    Atlas connector will be working only if configmap `atlas_connector.specifications.CONFIGMAP_NAME`
    will be created in k8s-itlabs-operator namespace.
    """
    atlas_annotations = AtlasConnectorAnnotationsFactory.annotations_from_dict(data=annotations)
    return AtlasConnectorService.on_upsert_pod(namespace=namespace, annotations=atlas_annotations)
