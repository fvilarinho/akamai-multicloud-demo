#!/bin/bash

# Locate prerequisites installations.
KUBECTL_CMD=$(which kubectl)

# Check if the Kubectl was found.
if [ ! -f "$KUBECTL_CMD" ]; then
  echo "Kubectl is not installed! Please install it first to continue!"

  exit 1
fi

# Apply the stack.
$KUBECTL_CMD apply -f kubernetes.yml
$KUBECTL_CMD rollout restart deployment nginx -n akamai-multicloud-demo

rm -f kubernetes.yml