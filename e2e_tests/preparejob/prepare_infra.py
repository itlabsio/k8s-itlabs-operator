import base64
from os import getenv

import hvac
import psycopg2
from hvac import exceptions
from kubernetes import client as k8s_client, config
from kubernetes.client import V1ConfigMap, V1ServiceAccount
from psycopg2 import sql


def configure_k8s_cluster(kube_api_url: str):
    try:
        config.load_incluster_config()
    except config.ConfigException:
        try:
            config.load_kube_config(context=kube_api_url)
        except config.ConfigException:
            raise Exception("Could not configure kubernetes client")


def get_token_and_cacrt_for_service_account(service_account_name: str, namespace: str):
    k8s_api_instance = k8s_client.CoreV1Api()
    service_account: V1ServiceAccount = k8s_api_instance.read_namespaced_service_account(
        name=service_account_name,
        namespace=namespace
    )
    token_resource_name = [s for s in service_account.secrets if 'token' in s.name][0].name
    secret = k8s_api_instance.read_namespaced_secret(
        name=token_resource_name, namespace=namespace)
    btoken = secret.data['token']
    token = base64.b64decode(btoken).decode()
    bcacrt = secret.data['ca.crt']
    cacrt = base64.b64decode(bcacrt).decode()
    return token, cacrt


def prepare_vault():
    # подключаемся к тестовому vault-серверу, включаем kubernetes auth method и создаем auth method для нашего кластера.
    # создаем отдельную роль для оператора и для тестового сервисаккаунта
    # Креды к созданной роли ложим в конфигмап в тестовый k8s-кластер
    vault_url = getenv('VAULT_URL')
    vault_k8s_auth_method = 'kube-ee'
    vault_k8s_role = 'k8s-itlabs-operator'
    kube_api_url = "https://kind-control-plane:6443"
    operator_name = 'e2e-k8s-itlabs-operator'
    policy_name = 'tester'
    namespace = 'k8s-itlabs-operator'
    service_account_names = ['k8s-itlabs-operator', 'e2e-k8s-itlabs-operator']

    configure_k8s_cluster(kube_api_url=kube_api_url)
    token, cacrt = get_token_and_cacrt_for_service_account(
        service_account_name=operator_name,
        namespace=namespace
    )
    client = hvac.Client(url=vault_url, token=getenv('OPERATOR_VAULT_TOKEN'))
    try:
        client.sys.enable_auth_method(
            method_type='kubernetes',
            path=vault_k8s_auth_method,
        )
    except exceptions.InvalidRequest:
        pass
    policy = '''
        path "*" {
            capabilities = ["create", "read", "update", "delete", "list"]
        }
    '''
    client.sys.create_or_update_policy(
        name=policy_name,
        policy=policy,
    )
    client.auth.kubernetes.configure(
        kube_api_url,
        kubernetes_ca_cert=cacrt,
        token_reviewer_jwt=token,
        mount_point=vault_k8s_auth_method,
    )
    client.auth.kubernetes.create_role(
        name=vault_k8s_role,
        bound_service_account_names=service_account_names,
        bound_service_account_namespaces=namespace,
        ttl=3600,
        policies=[policy_name],
        mount_point=vault_k8s_auth_method,
    )
    namespace = 'k8s-itlabs-operator'
    body = V1ConfigMap(
        api_version='v1',
        kind='ConfigMap',
        metadata={
            'name': 'k8s-itlabs-operator-config',
            'namespace': namespace,
        },
        data={
            'cluster_name': 'test-cluster',
            'vault_url': vault_url,
            'vault_k8s_auth_method': vault_k8s_auth_method,
            'vault_k8s_role': vault_k8s_role,
        }
    )
    try:
        k8s_client.CoreV1Api().read_namespaced_config_map(name='k8s-itlabs-operator-config', namespace=namespace)
    except Exception:
        pass
    else:
        k8s_client.CoreV1Api().delete_namespaced_config_map(name='k8s-itlabs-operator-config', namespace=namespace)
    k8s_client.CoreV1Api().create_namespaced_config_map(namespace, body)
    with open('/var/run/secrets/kubernetes.io/serviceaccount/token') as f:
        jwt = f.read()
        print('JWT:', jwt)
    vclient = hvac.Client(url=vault_url)
    # для дебага
    vclient.token = vclient.auth.kubernetes.login(
        'k8s-itlabs-operator', jwt, use_token=True, mount_point=vault_k8s_auth_method
    )


def prepare_postgres():
    conn = psycopg2.connect(
        database=getenv('PG_DB_NAME'),
        user=getenv('PG_USER_NAME'),
        password=getenv('PG_USER_PSWD'),
        host=getenv('PG_HOST'),
        port=int(getenv('PG_PORT'))
    )
    operator_user = str(getenv('OPERATOR_USER'))
    operator_pwd = getenv('OPERATOR_PASSWORD')
    conn.autocommit = True
    cursor = conn.cursor()
    query = """CREATE ROLE {} WITH ENCRYPTED PASSWORD %s LOGIN CREATEDB CREATEROLE;"""
    query = sql.SQL(query).format(*[sql.Identifier(operator_user)])
    values = [operator_pwd]
    cursor.execute(query, values)


def prepare_infra():
    prepare_vault()
    prepare_postgres()


def debug_vault():
    client = hvac.Client(url='http://0.0.0.0:8200', token='myroot')
    policies = client.sys.list_policies()
    print(policies)
    policy = '''
        path "*" {
            capabilities = ["create", "read", "update", "delete", "list"]
        }
    '''
    client.sys.create_or_update_policy(
        name='tester',
        policy=policy,
    )
    print('FUCK')
    client.auth.approle.create_or_update_approle(role_name='drole', token_policies=['tester'])
    resp = client.auth.approle.read_role_id(role_name='drole')
    print(resp)
    resp = client.auth.approle.read_role_id(role_name='drole')
    role_id = resp["data"]["role_id"]
    resp = client.auth.approle.generate_secret_id(role_name='drole')
    secret_id = resp["data"]["secret_id"]

    vclient = hvac.Client(url='http://0.0.0.0:8200')
    vclient.token = vclient.auth.approle.login(
        role_id=role_id,
        secret_id=secret_id,
    )['auth']['client_token']

    vclient.secrets.kv.v2.create_or_update_secret(path='pg', secret={'a': 'a'})
    sec = client.secrets.kv.v2.read_secret_version(path='pg')
    print('sec', sec)


def debug_pg():
    conn = psycopg2.connect(
        database='postgres',
        user='postgres',
        password='anypassword',
        host='0.0.0.0',
        port=5432
    )
    operator_user = str(getenv('OPERATOR_USER'))
    operator_pwd = getenv('OPERATOR_PASSWORD')
    conn.autocommit = True
    cursor = conn.cursor()
    query = """CREATE ROLE {} WITH ENCRYPTED PASSWORD %s LOGIN CREATEDB CREATEROLE;"""
    query = sql.SQL(query).format(*[sql.Identifier(operator_user)])
    values = [operator_pwd]
    cursor.execute(query, values)


if __name__ == "__main__":
    prepare_infra()
