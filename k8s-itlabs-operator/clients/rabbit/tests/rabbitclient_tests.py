import pytest

from clients.rabbit.rabbitclient import RabbitClient


@pytest.mark.skip(reason="This test contains real rabbit calls. It must run manually.")
class TestRabbitClientOnLocal:

    def test_create_rabbit_vhost(self):
        rabbit_client = RabbitClient(url='http://0.0.0.0:15672/', user='guest', password='guest')
        rabbit_client.create_rabbit_vhost('test_creation')
        data = rabbit_client.get_rabbit_vhost('test_creation')
        assert data

    def test_delete_rabbit_vhost(self):
        rabbit_client = RabbitClient(url='http://0.0.0.0:15672/', user='guest', password='guest')
        rabbit_client.delete_rabbit_vhost('test_creation')
        data = rabbit_client.get_rabbit_vhost('test_creation')
        assert not data

    def test_create_rabbit_user(self):
        rabbit_client = RabbitClient(url='http://0.0.0.0:15672/', user='guest', password='guest')
        rabbit_client.create_rabbit_user('test_user_creation', 'password')
        data = rabbit_client.get_rabbit_user('test_user_creation')
        assert data

    def test_delete_rabbit_user(self):
        rabbit_client = RabbitClient(url='http://0.0.0.0:15672/', user='guest', password='guest')
        data = rabbit_client.get_rabbit_user('test_user_creation')
        assert data
        data = rabbit_client.delete_rabbit_user('test_user_creation')
        assert not data

    def test_delete_user_vhost_permissions(self):
        user = 'test_user_creation'
        vhost = 'test_vhost_creation'
        rabbit_client = RabbitClient(url='http://0.0.0.0:15672/', user='guest', password='guest')
        user_data = rabbit_client.get_rabbit_user(user)
        if not user_data:
            rabbit_client.create_rabbit_user(user, 'password')
            user_data = rabbit_client.get_rabbit_user(user)
        assert user_data
        vhost_data = rabbit_client.get_rabbit_vhost(vhost)
        if not vhost_data:
            rabbit_client.create_rabbit_vhost(vhost)
            vhost_data = rabbit_client.get_rabbit_vhost(vhost)
        assert vhost_data
        perm_data = rabbit_client.get_user_vhost_permissions(user, vhost)
        if not perm_data:
            rabbit_client.create_user_vhost_permissions(user, vhost)
            perm_data = rabbit_client.get_user_vhost_permissions(user, vhost)
        assert perm_data

        rabbit_client.delete_rabbit_user(user)
        perm_data = rabbit_client.get_user_vhost_permissions(user, vhost)
        assert not perm_data

        rabbit_client.create_rabbit_user(user, 'password')
        rabbit_client.create_user_vhost_permissions(user, vhost)
        perm_data = rabbit_client.get_user_vhost_permissions(user, vhost)
        assert perm_data
        rabbit_client.delete_rabbit_vhost(vhost)
        perm_data = rabbit_client.get_user_vhost_permissions(user, vhost)
        assert not perm_data
