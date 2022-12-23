from clients.sentry.dto import SentryTeam, SentryProject, SentryProjectKey


class SentryTeamDtoFactory:
    @staticmethod
    def dto_from_dict(team: dict) -> SentryTeam:
        return SentryTeam(
            name=team.get("name"),
            slug=team.get("slug")
        )

    @staticmethod
    def dict_from_dto(team: SentryTeam) -> dict:
        data = {"name": team.name}
        if team.slug:
            data["slug"] = team.slug
        return data


class SentryProjectDtoFactory:
    @staticmethod
    def dto_from_dict(project: dict) -> SentryProject:
        return SentryProject(
            name=project.get("name"),
            slug=project.get("slug")
        )

    @staticmethod
    def dict_from_dto(project: SentryProject):
        data = {"name": project.name}
        if project.slug:
            data["slug"] = project.slug
        return data


class SentryProjectKeyDtoFactory:
    @staticmethod
    def dto_from_dict(project_key: dict) -> SentryProjectKey:
        dsn = project_key.get("dsn")
        return SentryProjectKey(
            name=project_key.get("name"),
            dsn=dsn.get("public")
        )
