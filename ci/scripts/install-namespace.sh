#!/usr/bin/env bash
set -e

source ci/scripts/common-func.sh

REQUIRED_ENV_VARS=(
  KEYVAL_FILE
  ART_USERNAME
  ART_PASSWORD
)

check_req_env_vars

export_keyval_env

# Generate a random 32 bits alphanumeric string
GENERATED_NAMESPACE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 | tr '[:upper:]' '[:lower:]')
# KEYVAL_FILE is used to share keyval pairs between steps
if [[ -f "$HOME/$KEYVAL_FILE" ]];then
  # Writing GENERATED_NAMESPACE to the keyval properties file
  echo "GENERATED_NAMESPACE=${GENERATED_NAMESPACE}" >> "$HOME/$KEYVAL_FILE"
fi

echo "Creating namespace $GENERATED_NAMESPACE"
kubectl create namespace ${GENERATED_NAMESPACE}
setup_kubectl_context

kubectl create secret docker-registry artifactory-registry-secret --docker-server=https://qliktech-docker-snapshot.jfrog.io/v1/ \
    --docker-username=${ART_USERNAME} --docker-password=${ART_PASSWORD} --docker-email=qlik-efe-reference-dev@qlik.com

kubectl create secret docker-registry artifactory-docker-secret --docker-server=https://qliktech-docker.jfrog.io/v1/ \
    --docker-username=${ART_USERNAME} --docker-password=${ART_PASSWORD} --docker-email=qlik-efe-reference-dev@qlik.com

kubectl label namespace ${GENERATED_NAMESPACE} app=component-ci
