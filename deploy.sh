#!/bin/bash

# Locate the required tools.
TERRAFORM_CMD=$(which terraform)

# Check if Terraform is installed.
if [ ! -f "$TERRAFORM_CMD" ]; then
  echo "Terraform not found! Please install it first to continue!"

  exit 1
fi

cd iac

# Create credentials.
./createCredentials.sh

# Execute the provisioning based on the IaC definition files.
$TERRAFORM_CMD init --upgrade

status=`echo $?`

if [ $status -eq 0 ]; then
  $TERRAFORM_CMD plan -var-file=$HOME/.environment.tfvars

  status=`echo $?`

  if [ $status -eq 0 ]; then
    $TERRAFORM_CMD apply -auto-approve \
                         -var-file=$HOME/.environment.tfvars

    status=`echo $?`
  fi
fi

cd ..

exit $status