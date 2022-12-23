from connectors.atlas_connector.services.atlas import AtlasService, AbstractAtlasService


class AtlasServiceFactory:
    @classmethod
    def create_atlas_service(cls, atlas_url: str, atlas_token: str) -> AbstractAtlasService:
        return AtlasService(
            atlas_url=atlas_url,
            atlas_token=atlas_token
        )
