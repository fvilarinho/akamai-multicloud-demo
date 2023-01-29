# Terraform definition.
terraform {
  # Required providers.
  required_providers {
    linode = {
      source  = "linode/linode"
    }
    aws = {
      source = "hashicorp/aws"
    }
    akamai = {
      source = "akamai/akamai"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}