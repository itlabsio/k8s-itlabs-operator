# k8s-itlabs-operator <sup>[RU](docs/ru/index.md)</sup>

Kubernetes operator for configure environment for you deployed microservice

## Requirements

Please check that next points are done before deploying operator:

- Namespace `k8s-itlabs-operator` was created.
- Secret `docker-registry-secret` is exists in `k8s-itlabs-operator` namespace.
- Cert-manager operator is installed.
- Manifest kubernetes-manual/rbac.yaml was applied.
- Configmap `k8s-itlabs-operator-config` was created with next fields:
    - cluster_name;
    - vault_url;
    - vault_k8s_auth_method;
    - vault_k8s_role.
  
  Example:

  ```shell
  kubectl create configmap -n k8s-itlabs-operator k8s-itlabs-operator-config \
    --from-literal=vault_url=https://vault.io/ \
    --from-literal=vault_k8s_auth_method=kube-dev \
    --from-literal=vault_k8s_role=k8s-itlabs-operator
  ```

- Secret `itlabs-operator-sentry-dsn` was created with key `sentry_dsn`. Operator
will not send data to Sentry if this secret does not exist.

## Testing

For run e2e-tests locally, execute commands:

```shell
chmod +x scripts/run-tests.sh
./scripts/run-tests.sh
```

## Monitoring

To collect operator's metrics, you can send request to service in k8s-cluster
to named port `metrics` or `8080`

Collected metrics:
- app_http_request_operator_latency_seconds - to measure incoming requests 
- app_http_request_operator_client_latency_seconds - to measure outgoing requests
