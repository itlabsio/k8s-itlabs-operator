# k8s-itlabs-operator

Примеры работы с операторами доступны [тут](scheme.md).

## Требования

Пожалуйста, убедитесь что все следующие пункты выполнены перед развертыванием
оператора:

- В кластере создано пространство имен `k8s-itlabs-operator`.
- Создан секрет `docker-registry-secret` в пространстве имен `k8s-itlabs-operator`.
- Установлен оператор cert-manager.
- Применен манифест из файла kubernetes-manual/rbac.yaml.
- Создан конфигмап `k8s-itlabs-operator-config` со следующими полями:
    - cluster_name;
    - vault_url;
    - vault_k8s_auth_method;
    - vault_k8s_role.
  
  Пример:

  ```shell
  kubectl create configmap -n k8s-itlabs-operator k8s-itlabs-operator-config \
    --from-literal=vault_url=https://vault.io/ \
    --from-literal=vault_k8s_auth_method=kube-dev \
    --from-literal=vault_k8s_role=k8s-itlabs-operator
  ```

- Создан секрет `itlabs-operator-sentry-dsn` c ключом `sentry_dsn`. Оператор
не будет отправлять данные в Sentry, если данный секрет не будет создан.

## Локальный запуск e2e-тестов

Для локального запуска e2e-тестов выполните команды:

```shell
chmod +x scripts/start_local_runner.sh
./scripts/start_local_runner.sh
```
