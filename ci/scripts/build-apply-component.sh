#!/usr/bin/env bash
set -e

source ci/scripts/common-func.sh

REQUIRED_ENV_VARS=(GENERATED_NAMESPACE)

export_keyval_env

check_req_env_vars

setup_kubectl_context

[ -d ci/configs/${TARGET_PLATFORM} ] && cd ci/configs/${TARGET_PLATFORM}/values
## Substitute the GENERATED_NAMESPACE in the releaseNamespace.yaml patch
cat releaseNamespace.yaml | envsubst > processedReleaseNamespace.yaml
cat processedReleaseNamespace.yaml > releaseNamespace.yaml
rm -f processedReleaseNamespace.yaml

cd ..
yq w -i kustomization.yaml namespace ${GENERATED_NAMESPACE}
kustomize build . --enable_alpha_plugins | kubectl apply -f -
