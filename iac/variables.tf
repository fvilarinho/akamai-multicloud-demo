# Settings filename.
variable "settingsFilename" {
  type = string
}

# SSH private key filename.
variable "privateKeyFilename" {
  type = string
}

# DigitalOcean API token.
variable "digitaloceanToken" {
  type = string
}

# Linode API token.
variable "linodeToken" {
  type = string
}

# AWS access key.
variable "awsAccessKey" {
  type = string
}

# AWS secret key.
variable "awsSecretKey" {
  type = string
}

# Akamai account ID.
variable "edgeGridAccountKey" {
  type = string
}

# Akamai EdgeGrid API host.
variable "edgeGridHost" {
  type = string
}

# Akamai EdgeGrid API access token.
variable "edgeGridAccessToken" {
  type = string
}

# Akamai EdgeGrid API client token.
variable "edgeGridClientToken" {
  type = string
}

# Akamai EdgeGrid API client secret.
variable "edgeGridClientSecret" {
  type = string
}

variable "network" {
  type = string
  default = "STAGING"
}