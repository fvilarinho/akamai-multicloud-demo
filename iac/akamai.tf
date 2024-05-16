# Akamai provider definition.
provider "akamai" {
  config {
    account_key   = var.edgeGridAccountKey
    host          = var.edgeGridHost
    access_token  = var.edgeGridAccessToken
    client_token  = var.edgeGridClientToken
    client_secret = var.edgeGridClientSecret
  }
}