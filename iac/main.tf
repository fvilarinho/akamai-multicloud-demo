# Terraform definition.
terraform {
  # State management definition.
  backend "s3" {
    bucket                      = "fvilarin-devops"
    key                         = "akamai-multicloud-demo.tfstate"
    region                      = "us-east-1"
    endpoint                    = "us-east-1.linodeobjects.com"
    skip_credentials_validation = true
  }

  # Required providers.
  required_providers {
    linode = {
      source  = "linode/linode"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Defines the required local variables.
locals {
  credentialsFilename = pathexpand(var.credentialsFilename)
  settingsFilename    = pathexpand(var.settingsFilename)
  settings            = jsondecode(chomp(file(local.settingsFilename)))
}