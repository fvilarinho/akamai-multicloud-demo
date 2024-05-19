# Definition of the Edge Hostname. This is the hostname that must be used in the Edge DNS entries
# of all hostnames that will pass through the CDN.
resource "akamai_edge_hostname" "default" {
  edge_hostname = "${local.settings.name}.${local.settings.akamai.domain}.edgesuite.net"
  contract_id   = local.settings.akamai.contract
  group_id      = local.settings.akamai.group
  product_id    = local.settings.akamai.property.product
  ip_behavior   = local.settings.akamai.property.ipVersion
}