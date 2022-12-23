class InfrastructureServiceProblem(Exception):
    def __init__(self, infra_service_name: str, ex: Exception):
        message = f"Raised a problem with infrastructure service '{infra_service_name}', reason is {type(ex)}:{ex}"
        super().__init__(message)
