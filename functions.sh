#!/bin/bash

# Shows the labels.
function showLabel() {
  if [[ "$0" == *"undeploy.sh"* ]]; then
    echo "** Undeploy ** "
  elif [[ "$0" == *"deploy.sh"* ]]; then
    echo "** Deploy ** "
  fi

  echo
}

# Shows the banner.
function showBanner() {
  if [ -f "banner.txt" ]; then
    cat banner.txt
  fi

  showLabel
}

# Gets a credential value.
function getCredential() {
  if [ -f "$CREDENTIALS_FILENAME" ]; then
    value=$(awk -F'=' '/'$1'/,/^\s*$/{ if($1~/'$2'/) { print substr($0, length($1) + 2) } }' "$CREDENTIALS_FILENAME" | tr -d '"' | tr -d ' ')
  else
    value=
  fi

  echo "$value"
}

# Checks the dependencies of this script.
function checkDependencies() {
  # Finds terraform binary.
  export TERRAFORM_CMD=$(which terraform)

  # Checks if terraform is installed.
  if [ -z "$TERRAFORM_CMD" ]; then
    echo "Terraform is not installed! Please install it first to continue!"

    exit 1
  fi

  export KUBECTL_CMD=$(which kubectl)

  # Check if the Kubectl was found.
  if [ ! -f "$KUBECTL_CMD" ]; then
    echo "Kubectl is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Prepares the environment to execute the commands of this script.
function prepareToExecute() {
  # Mandatory files/paths.
  export WORK_DIR="$PWD/iac"
  export CREDENTIALS_FILENAME="$WORK_DIR"/.credentials
  export SETTINGS_FILENAME="$WORK_DIR"/settings.json
  export PRIVATE_KEY_FILENAME="$WORK_DIR"/.id_rsa
  export IDENTIFIER=multicloud
  export KUBECONFIG_FILENAME="$WORK_DIR"/.kubeconfig

  # Environment variables.
  export TF_VAR_credentialsFilename="$CREDENTIALS_FILENAME"
  export TF_VAR_settingsFilename="$SETTINGS_FILENAME"
  export TF_VAR_privateKeyFilename="$PRIVATE_KEY_FILENAME"
  export TF_VAR_identifier="$IDENTIFIER"
  export TF_VAR_awsAccessKey=$(getCredential "aws" "aws_access_key_id")
  export TF_VAR_awsSecretKey=$(getCredential "aws" "aws_secret_access_key")
}

checkDependencies
prepareToExecute