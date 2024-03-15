class RabbitClientError(Exception):
    message = ""

    def __init__(self, response):
        content = response.content.decode("UTF-8") if response.content else ""
        self.message = f"Rabbit api call error: {content}"

    def __str__(self):
        return str(self.message)
