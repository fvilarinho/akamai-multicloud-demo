# Definition of the Edge DNS entry for the TLS certificate validation.
data "akamai_property_hostnames" "default" {
  contract_id = local.settings.akamai.contract
  group_id    = local.settings.akamai.group
  property_id = akamai_property.default.id
  version     = akamai_property.default.latest_version
  depends_on  = [ akamai_property.default ]
}

resource "akamai_dns_record" "certificateValidation" {
  name       = data.akamai_property_hostnames.default.hostnames[0].cert_status[0].hostname
  recordtype = "CNAME"
  ttl        = 30
  zone       = local.settings.akamai.domain
  target     = [data.akamai_property_hostnames.default.hostnames[0].cert_status[0].target]
  depends_on = [data.akamai_property_hostnames.default]
}

# Definition of the Edge DNS entry for the property.
resource "akamai_dns_record" "default" {
  name       = "${local.settings.name}.${local.settings.akamai.domain}"
  recordtype = "CNAME"
  ttl        = 30
  zone       = local.settings.akamai.domain
  target     = [ "${local.settings.name}.${local.settings.akamai.domain}.edgesuite-staging.net" ]
}