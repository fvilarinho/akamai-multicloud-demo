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

# Prepares the environment to execute the commands of this script.
function prepareToExecute() {
  # Required files/paths.
  export WORK_DIR="$PWD/iac"
  export CREDENTIALS_FILENAME="$WORK_DIR"/.credentials
  export SETTINGS_FILENAME="$WORK_DIR"/settings.json
  export PRIVATE_KEY_FILENAME="$WORK_DIR"/.id_rsa
  export KUBECONFIG_FILENAME="$WORK_DIR"/.kubeconfig

  # Required binaries.
  export TERRAFORM_CMD=$(which terraform)
  export KUBECTL_CMD=$(which kubectl)

  # Environment variables.
  export TF_VAR_settingsFilename="$SETTINGS_FILENAME"
  export TF_VAR_privateKeyFilename="$PRIVATE_KEY_FILENAME"
  export TF_VAR_digitaloceanToken=$(getCredential "digitalocean" "token")
  export TF_VAR_linodeToken=$(getCredential "linode" "token")
  export TF_VAR_awsAccessKey=$(getCredential "aws" "aws_access_key_id")
  export TF_VAR_awsSecretKey=$(getCredential "aws" "aws_secret_access_key")
  export TF_VAR_edgeGridAccountKey=$(getCredential "edgegrid" "account_key")
  export TF_VAR_edgeGridHost=$(getCredential "edgegrid" "host")
  export TF_VAR_edgeGridAccessToken=$(getCredential "edgegrid" "access_token")
  export TF_VAR_edgeGridClientToken=$(getCredential "edgegrid" "client_token")
  export TF_VAR_edgeGridClientSecret=$(getCredential "edgegrid" "client_secret")
}

prepareToExecute