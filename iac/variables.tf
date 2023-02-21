variable "application" {
  description = "Application attributes."
  default = {
    label      = "multicloud"
    token      = "token"
    publicKey  = "publicKey"
    privateKey = "privateKey"
    hostname   = "hostname"
    domain     = "domain"
    email      = "email"
  }
}

variable "linode" {
  description = "Linode attributes."
  default = {
    region  = "us-east"
    token   = "token"
    manager = {
      label = "multicloud-manager"
      type  = "g6-nanode-1"
      os    = "linode/debian11"
      user  = "user"
    }
    worker = {
      label = "multicloud-worker1"
      type  = "g6-nanode-1"
      os    = "linode/debian11"
      user  = "user"
    }
  }
}

variable "aws" {
  description = "AWS attributes."
  default     = {
    region    = "us-east-1"
    accessKey = "accessKey"
    secretKey = "secretKey"
    worker    = {
      label = "multicloud-worker2"
      type  = "t2.micro"
      os    = "ami-052465340e6b59fc0"
      user  = "user"
    }
  }
}

variable "azure" {
  default = {
    region       = "East US"
    subscription = "subscription"
    tenant       = "tenant"
    worker       = {
      label = "multicloud-worker3"
      type  = "Standard_B1s"
      os    = {
        id      = "UbuntuServer"
        vendor  = "Canonical"
        version = "18.04-LTS"
      }
      user = "user"
    }
  }
}

variable "akamai" {
  description = "Akamai attributes."
  default = {
    edgegrid = {
      apiHostname  = "apiHostname"
      accessToken  = "accessToken"
      clientToken  = "clientToken"
      clientSecret = "clientSecret"
    }
    account  = "account"
    contract = "contract"
    group    = "group"
    product  = "product"
    property = {
      edgeHostname = "edgeHostname"
    }
    balancer = {
      type        = "weighted"
      method      = "weighted-round-robin"
      domain      = "domain"
      host        = "host"
      aggregation = "median"
      mode        = "normal"
      healthCheck = {
        protocol                = "HTTP"
        port                    = 80
        path                    = "/"
        interval                = 60
        timeout                 = 10
        consider_redirects      = false
        consider_not_found      = true
        consider_internal_error = true
      }
    }
  }
}