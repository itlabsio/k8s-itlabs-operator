#!/bin/sh

prepare_kind() {
  apk add -U wget
  apk add -U gettext

  # установка kind
  wget -O /usr/local/bin/kind https://github.com/kubernetes-sigs/kind/releases/download/${KIND}/kind-linux-amd64
  chmod +x /usr/local/bin/kind

  # установка kubectl
  wget -O /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL}/bin/linux/amd64/kubectl
  chmod +x /usr/local/bin/kubectl
}

prepare_cluster() {
  kind get clusters
  clusters="$(kind get clusters)"
  if [[ "$clusters" != "No kind clusters found." ]]; then
    kind delete cluster
  fi
  if [[ $VM_IP ]]; then
    export REAL_IP=$VM_IP
  else
    export REAL_IP=$(ip route|awk '/default/ { print $3 }')
  fi
  echo "REAL_IP", $REAL_IP
  sed -i -E -e "s/here_should_be_real_ip/$REAL_IP/g" "e2e_tests/kind/kind-config.yaml"
  kind create cluster --config=./e2e_tests/kind/kind-config.yaml
  sed -i -E -e "s/localhost|0\.0\.0\.0/$REAL_IP/g" "$HOME/.kube/config"
}

prepare_namespace(){
  kubectl create namespace k8s-itlabs-operator
}

prepare_serviceaccount() {
  kubectl apply -f ./manifests/serviceaccount.yaml
}

prepare_registry_creds() {
  kubectl create secret docker-registry -n k8s-itlabs-operator docker-registry-secret --docker-server=$CI_REGISTRY --docker-username=$CI_REGISTRY_USER --docker-password=$CI_REGISTRY_PASSWORD --docker-email=$GITLAB_USER_EMAIL
}

prepare_rbac() {
  kubectl apply -f ./manifests/rbac.yaml
}

prepare_certmanager() {
  kubectl apply --wait=true -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml
  kubectl wait deployment -n cert-manager --all --for condition=Available=True --timeout=90s
}


prepare_kind
prepare_cluster
prepare_namespace
prepare_serviceaccount
prepare_registry_creds
prepare_rbac
prepare_certmanager
