#!/usr/bin/env bash
set -e

source ci/scripts/common-func.sh

REQUIRED_ENV_VARS=(TARGET_PLATFORM)

export_keyval_env

check_req_env_vars

if [ ! -z ${TARGET_PLATFORM} ]; then
  case ${TARGET_PLATFORM} in
    gke)
      echo ${GKE_USER_SERVICE_ACCOUNT} > serviceAccount.json
      gcloud auth activate-service-account --key-file serviceAccount.json
      gcloud container clusters get-credentials ${TARGET_CLUSTER} --region ${REGION} --project ${CLOUDSDK_CORE_PROJECT}
      ;;
    *) ;;
  esac
fi
