#!/usr/bin/env bash

check_req_env_vars () {
  for env_var in "${REQUIRED_ENV_VARS[@]}" ; do
    eval env_var_val=\$$env_var
    if [[ -z "$env_var_val" ]]; then
        echo "$env_var environment variable must be set"
        exit 1
    fi
  done
}

export_keyval_env () {
  if [[ -f "$HOME/$KEYVAL_FILE" ]]
   then
      while IFS= read -r var
      do
        if [[ ! -z "$var" && `echo $var | grep -E "GENERATED_NAMESPACE|TAG"` ]]
        then
          export "$var"
        fi
      done < "$HOME/$KEYVAL_FILE"
  fi
}

setup_kubectl_context () {
  kubectl config set-context $(kubectl config current-context) --namespace=$GENERATED_NAMESPACE
}

delete_namespace () {
  namespace=$1
  errno=0
  kubectl get namespaces | grep -w $namespace || errno=$?
  if [ $errno -eq 0 ]; then
    kubectl delete deployments --all --grace-period=0 --force -n $namespace
    kubectl delete statefulset --all --grace-period=0 --force -n $namespace
    kubectl delete services --all --grace-period=0 --force -n $namespace
    kubectl delete job --all --grace-period=0 --force -n $namespace
    kubectl delete pods --all --grace-period=0 --force -n $namespace
    kubectl delete pvc --all --grace-period=0 --force -n $namespace

    kubectl delete namespace --grace-period=0 --force --wait=false $namespace
  else
    echo "$namespace namespace does not exit."
    exit 1
  fi
}
