payload="$(mktemp "$TMPDIR/k8s-resource-request.XXXXXX")"
cat > "$payload" <&0


function setup() {
  DEBUG=$(jq 'map(.debug | tostring == "true") | any' < "$payload")
  if [[ "$DEBUG" == "true" ]]; then
      echo "Enabling debug mode."
      set -x
  fi
  KUBECTL=$(jq -r '.source.kubectl_path // "/usr/local/bin/kubectl"' < "$payload")
  pwd
  KUBECTL=$(readlink -f "$KUBECTL")

  # For DRY_RUN, don't actually run any commands
  # Checks both .params.dry_run and .source.dry_run
  DRY_RUN=$(jq 'map(.dry_run | tostring == "true") | any' < "$payload")
  if [[ $DRY_RUN == "true" ]]; then
      KUBECTL="$KUBECTL --dry-run"
  fi


  # When using a kubectl proxy sidecar, the cluster_url is dynamic.
  # Run a command to find the URL.
  USE_SIDECAR_KUBECTL_PROXY=$(jq -r .source.use_sidecar_kubectl_proxy < "$payload")
  if [[ "$USE_SIDECAR_KUBECTL_PROXY" == "true" ]]; then
      CLUSTER_URL="$(ip route | grep default | head -n 1 | cut -f 3 -d ' '):8001"
  else
      CLUSTER_URL=$(jq -r .source.cluster_url < "$payload")
  fi
  KUBECTL="$KUBECTL --server=$CLUSTER_URL"

  # Setup namespace so any conflicts cause a failure
  NAMESPACE=$(jq -r .source.namespace < "$payload")
  if [[ "$NAMESPACE" != "null" ]]; then
      KUBECTL="$KUBECTL --namespace=$NAMESPACE"
  fi

  # configure SSL Certs if available
  if [[ "$CLUSTER_URL" =~ https.* ]]; then
      pwd=$(dirname $0)

      KUBE_CA=$(jq -r .source.cluster_ca < "$payload")
      KUBE_KEY=$(jq -r .source.admin_key < "$payload")
      KUBE_CERT=$(jq -r .source.admin_cert < "$payload")
      CA_PATH="/$pwd/ca.pem"
      KEY_PATH="/$pwd/key.pem"
      CERT_PATH="/$pwd/cert.pem"

      if [[ $DRY_RUN == "false" ]]; then
      # Don't actually write any files in DRY_RUN
          echo "$KUBE_CA" | base64 -d > $CA_PATH
          echo "$KUBE_KEY" | base64 -d > $KEY_PATH
          echo "$KUBE_CERT" | base64 -d > $CERT_PATH
      fi

      KUBECTL="$KUBECTL --certificate-authority=$CA_PATH --client-key=$KEY_PATH --client-certificate=$CERT_PATH"
  fi

  export KUBECTL
  export DRY_RUN
}


function get_version_info() {
  KUBECTL_METADATA_SELECTOR="{name:.metadata.name, resourceVersion:.metadata.resourceVersion, images:[.spec.template.spec.containers[].image]}"

  export METADATA=$($KUBECTL get deployments -ojson | jq ".items | map($KUBECTL_METADATA_SELECTOR)")
  export VERSION=$(echo "$METADATA" | jq 'map({(.name) : .resourceVersion}) | add')
  export RESULT="{\"version\":$VERSION, \"metadata\":$METADATA}"
}

setup