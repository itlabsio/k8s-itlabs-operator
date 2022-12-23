from connectors.atlas_connector.dto import AtlasMicroserviceDto


class AtlasMicroserviceDtoPresenter:
    @classmethod
    def atlas_dict_from_dto(cls, atlas_ms_dto: AtlasMicroserviceDto) -> dict:
        data = {
            'clusterDns': atlas_ms_dto.cluster_dns,
            'namespace': atlas_ms_dto.namespace,
            'msName': atlas_ms_dto.ms_name,
            'gitlabProjectId': atlas_ms_dto.gitlab_project_id,
        }
        if atlas_ms_dto.business_name:
            data['businessName'] = atlas_ms_dto.business_name
        return data
