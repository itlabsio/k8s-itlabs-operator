from clients.postgres.postgresclient import AbstractPostgresClient


class MockedPostgresClient(AbstractPostgresClient):
    def __init__(self, db_exist: bool, user_exist: bool):
        self.db_exist = db_exist
        self.user_exist = user_exist
        self.db_create_call_count = 0
        self.user_create_call_count = 0
        self.user_alter_password_call_count = 0
        self.grant_call_count = 0
        self.grant_user_to_admin_call_count = 0

    def is_user_exist(self, user: str) -> bool:
        return self.user_exist

    def is_database_exist(self, db_name: str) -> bool:
        return self.db_exist

    def create_user(self, user: str, password: str):
        self.user_create_call_count += 1

    def alter_user_password(self, user: str, password: str):
        self.user_alter_password_call_count += 1

    def create_database(self, db_name: str, user: str):
        self.db_create_call_count += 1

    def grant_all_privileges(self, db_name: str, user: str):
        self.grant_call_count += 1

    def grant_user_to_admin(self, user: str):
        self.grant_user_to_admin_call_count += 1
