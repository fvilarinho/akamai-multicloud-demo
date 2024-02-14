#!/bin/bash

# Prepares the environment to execute this script.
function prepareToExecute() {
  cd .. || exit 1

  source functions.sh

  cd iac || exit 1
}

# Downloads and prepares the kubeconfig file. It is required to connect to the K3S cluster.
function downloadAndPrepareKubeconfig() {
  # Downloads the kubeconfig file.
  scp -q \
      -o "UserKnownHostsFile=/dev/null" \
      -o "StrictHostKeyChecking=no" \
      -i "$PRIVATE_KEY_FILENAME" \
      "$USER"@"$MANAGER_NODE":/etc/rancher/k3s/k3s.yaml \
      "$KUBECONFIG_FILENAME"

  # Prepares the kubeconfig file.
  cp -f "$KUBECONFIG_FILENAME" "$KUBECONFIG_FILENAME".tmp

  sed -i -e 's|127.0.0.1|'"$MANAGER_NODE"'|g' "$KUBECONFIG_FILENAME".tmp

  cp -f "$KUBECONFIG_FILENAME".tmp "$KUBECONFIG_FILENAME"

  rm -f "$KUBECONFIG_FILENAME".tmp*
}

# Apply the stack.
function applyStack() {
  export KUBECONFIG="$KUBECONFIG_FILENAME"

  $KUBECTL_CMD apply -f k3s-stack.yml
}

# Main function.
function main() {
  prepareToExecute
  downloadAndPrepareKubeconfig
  applyStack
}

main