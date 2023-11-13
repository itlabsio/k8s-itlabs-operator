#!/bin/sh

prepare_image() {
  # build images of operator and fixture for preparing environment for tests
  docker build -t "$DOCKER_IMAGE" -f docker/Dockerfile .
  docker build -t prepare_infra -f e2e_tests/preparejob/prepare.infra.Dockerfile .
  kind load docker-image prepare_infra
  kind load docker-image "$DOCKER_IMAGE"
}

prepare_infrastructure() {
  # create infrastructure
  # start jobs in kind for preparing vault and postgres
  # wait job's end
  export POSTGRES_PASSWORD='anypassword'
  export POSTGRES_USER='postgres'
  export POSTGRES_DB='postgres'
  export OPERATOR_USER='operator'
  export OPERATOR_PASSWORD='operator_pwd'
  if ! docker-compose -p e2e-infrastructure -f e2e_tests/services/docker-compose-infra.yaml up -d --wait; then
    exit 1;
  fi

  envsubst < e2e_tests/preparejob/k8s-prepare-infrastructure-job.yaml > k8s-prepare-infrastructure-job-no-var.yaml
  kubectl apply -f e2e_tests/kind/e2e-rbac.yaml
  kubectl apply -f e2e_tests/kind/crd-servicemonitor.yaml
  kubectl apply -f k8s-prepare-infrastructure-job-no-var.yaml
  kubectl -n k8s-itlabs-operator wait --for=condition=complete --timeout=180s job/k8s-itlabs-operator-prepare-infra
}

e2e_tests() {
  # check configmap is created with credentials for vault
  operator_configmap=`kubectl get configmap -n k8s-itlabs-operator k8s-itlabs-operator-config  --ignore-not-found`
  if [ -z "$operator_configmap" ]; then
    echo Configmap for k8s-itlabs-operator deployment was not created
    exit 1
  fi

  # replace variables in manifest by values
  chmod +x scripts/update-manifests.sh
  ./scripts/update-manifests.sh
  # deploy operator into kind
  kubectl apply -k "${MANIFEST_FOLDER}"
  kubectl apply -f e2e_tests/operator/cert-manager.yaml
  kubectl wait deployment -n k8s-itlabs-operator --all --for condition=Available=True --timeout=300s

  # wait until coredns will be ready
  kubectl rollout status deployment coredns -n kube-system
  kubectl wait pods -n kube-system -l k8s-app=kube-dns --for condition=Ready

  kubectl get svc -n k8s-itlabs-operator k8s-itlabs-operator
  kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
  time kubectl wait pods dnsutils --for condition=Ready --timeout=300s # up timeout
  kubectl exec -i -t dnsutils -- nslookup k8s-itlabs-operator.k8s-itlabs-operator

  # add secret with credential to sentry, token and organization have been taken from sentry db dump, that is why they
  # are not sensitive
  kubectl create secret generic sentry-creds \
    -n k8s-itlabs-operator \
    --from-literal=sentry_token="1685afd6688d4d92837fcd763453407ae082f0c4291f4e3aa72b25a159632f49" \
    --from-literal=sentry_organization="sentry"

  # secret for root access to keycloak (for keycloak_tests)
  kubectl create secret generic keycloak-creds \
    -n k8s-itlabs-operator \
    --from-literal=username="admin" \
    --from-literal=password="admin"

  # start e2e tests
  envsubst < e2e_tests/tester/job-e2e-tests.yaml > job-e2e-tests-no-var.yaml
  kubectl apply -f job-e2e-tests-no-var.yaml
  kubectl wait job/e2e-tests -n k8s-itlabs-operator --for=condition=complete --timeout=360s > /dev/null && exit 0 &
  completion_pid=$!
  kubectl wait job/e2e-tests -n k8s-itlabs-operator --for=condition=failed --timeout=360s > /dev/null && exit 1 &
  failure_pid=$!



  echo "Running tests"
  is_tests_running=true
  runtime_duration=0
  exit_code=0
  while "$is_tests_running"; do
    sleep 1

    if ! ps -p $failure_pid > /dev/null; then
      is_tests_running=false
      exit_code=1
    fi

    if ! ps -p $completion_pid > /dev/null; then
      is_tests_running=false
    fi

    runtime_duration=$((runtime_duration + 1))
    printf "\truntime: %s" "$(date -d@$runtime_duration -u +%H:%M:%S)"
    if [ $is_tests_running ]; then printf '\r'; else printf '\n'; fi
  done

  if [ "$exit_code" = "0" ]; then
    echo "Tests passed"
    pkill -P $failure_pid
  else
    echo "Tests failed"
    pkill -P $completion_pid
  fi

  kubectl logs -n k8s-itlabs-operator  -l job-name=e2e-tests -c e2e-tests --tail=-1

  docker-compose -p e2e-infrastructure -f e2e_tests/services/docker-compose-infra.yaml down
  exit $exit_code
}

if [ "$VM_IP" ]; then
  REAL_IP=$VM_IP
else
  REAL_IP=$(ip route|awk '/default/ { print $3 }')

fi
export REAL_IP
echo REAL_IP "$REAL_IP"

# prepare kubernetes cluster for tests
chmod +x e2e_tests/kind/prepare-kind.sh
./e2e_tests/kind/prepare-kind.sh
prepare_image
prepare_infrastructure
e2e_tests
