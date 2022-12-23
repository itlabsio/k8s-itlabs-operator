from clients.keycloak.dto import Token, ClientDto, Error


class TokenDtoFactory:
    @staticmethod
    def dto_from_dict(data: dict) -> Token:
        return Token(access_token=data["access_token"])


class ClientDtoFactory:
    @staticmethod
    def dto_from_dict(data: dict) -> ClientDto:
        return ClientDto(
            id=data.get("id"),
            client_id=data.get("clientId"),
            name=data.get("name"),
            protocol=data.get("protocol"),
            client_authenticator_type=data.get("clientAuthenticatorType"),
        )

    @staticmethod
    def dict_from_dto(data: ClientDto) -> dict:
        return {
            "clientId": data.client_id,
            "name": data.name,
            "protocol": data.protocol,
            "clientAuthenticatorType": data.client_authenticator_type,
        }


class ErrorDtoFactory:
    @staticmethod
    def dto_from_dict(data: dict) -> Error:
        message = data.get("error") or data.get("errorMessage")
        return Error(message=message)
